require 'stringio'

class Object
  def find_method(*args, &block)
    if block_given?
      MethodFinder.methods_to_try(self).select do |met|
        self.class.class_eval %{ alias :unknown #{met} }
        obj = self.dup rescue self
        yield obj rescue nil
      end
    else
      MethodFinder.find(self, *args)
    end
  end
end

class MethodFinder
  ARGS = {
    :cycle => [1] # prevent cycling forever
  }

  # Blacklisting methods, e.g. { :Object => [:ri, :vim] }
  INSTANCE_METHOD_BLACKLIST = Hash.new { |h, k| h[k] = [] }
  CLASS_METHOD_BLACKLIST = Hash.new { |h, k| h[k] = [] }

  INSTANCE_METHOD_BLACKLIST[:Object] << :find_method # prevent stack overflow
  INSTANCE_METHOD_BLACKLIST[:Object] << :gem # funny testing stuff w/ Bundler

  if defined? Pry
    INSTANCE_METHOD_BLACKLIST[:Object] << :pry
    CLASS_METHOD_BLACKLIST[:Object] << :pry
  end

  class << self
    def find(obj, res, *args, &block)
      redirect_streams

      methods_to_try(obj).select do |met|
        o = obj.dup rescue obj
        m = o.method(met)
        if m.arity <= args.size
          a = args.empty? && ARGS.has_key?(met) ? ARGS[met] : args
          m.call(*a, &block) == res rescue nil
        end
      end
    ensure
      restore_streams
    end

    # Added by Jan Lelis
    def methods_to_try(obj)
      ret = obj.methods.map(&:intern)
      blacklist = obj.is_a?(Module) ? CLASS_METHOD_BLACKLIST : INSTANCE_METHOD_BLACKLIST
      klass = obj.is_a?(Module) ? obj : obj.class

      klass.ancestors.each { |ancestor| ret -= blacklist[ancestor.to_s.intern] }

      # 1.8.7 lacks Symbol#<=>
      ret.sort_by(&:to_s)
    end

    def find_classes_and_modules
      constants = Object.constants.sort.map { |c| Object.const_get(c) }
      constants.select { |c| c.class == Class || c.class == Module}
    end

    def find_in_class_or_module(c, pattern=/./)
      cs = Object.const_get(c.to_s)
      class_methods = cs.methods(false) rescue []
      instance_methods = cs.instance_methods(false)
      all_methods = class_methods + instance_methods
      all_methods.grep(/#{pattern}/).sort
    end

    def redirect_streams
      @orig_stdout = $stdout
      @orig_stderr = $stderr
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    def restore_streams
      $stdout = @orig_stdout
      $stderr = @orig_stderr
    end
  end
  private_class_method :redirect_streams, :restore_streams
end

