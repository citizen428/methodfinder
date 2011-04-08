require 'stringio'

class Object
  def find_method(*args, &block)
    self.methods.sort.map(&:intern).select do |met|
      self.class.class_eval %{ alias :unknown #{met} }
        obj = self.dup rescue self
        yield obj rescue nil
      end
    end
  end

  class MethodFinder
    ARGS = {
      :cycle => [1] # prevent cycling forever
    }

    class << self
      def find_classes_and_modules
        constants = Object.constants.sort.map { |c| Object.const_get(c) }
        constants.select { |c| c.class == Class || c.class == Module}
      end

      def find(obj, res, *args, &block)
        redirect_streams

        obj.methods.sort.map(&:intern).select do |met|
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

