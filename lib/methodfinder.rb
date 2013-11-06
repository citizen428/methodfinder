require 'stringio'

class Object
  # An alternative interface to the functionality of
  # <tt>MethodFinder.find</tt>. Also allows to test for state other
  # than the return value of the method.
  #
  #    %w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
  #    #=> ["Array#delete_at", "Array#slice!"]
  #    10.find_method { |n| n.unknown(3) == 1 }
  #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]
  #
  # Inside <tt>find_method</tt>'s block, the receiver is available as
  # block argument and the special method <tt>unknown</tt> is used as
  # a placeholder for the desired method.
  #
  # <tt>find_method</tt> can be called without passing a block. This
  # is the same as calling <tt>MethodFinder.find</tt>.
  #
  #    10.find_method(1,3)
  #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]

  def find_method(*args, &block)
    if block
      mets = MethodFinder.methods_to_try(self).select do |met|
        self.class.class_eval("alias :unknown #{met}")
        obj = self.dup rescue self # dup doesn't work for immutable types
        block.call(obj) rescue nil
      end
      mets.map { |m| "#{self.method(m).owner}##{m}" }
    else
      MethodFinder.find(self, *args)
    end
  end
end

module MethodFinder
  # Default arguments for methods
  ARGS = {
    cycle: [1] # prevent cycling forever
  }

  # Blacklisting methods, e.g. { :Object => [:ri, :vim] }
  INSTANCE_METHOD_BLACKLIST = Hash.new { |h, k| h[k] = [] }
  CLASS_METHOD_BLACKLIST = Hash.new { |h, k| h[k] = [] }

  INSTANCE_METHOD_BLACKLIST[:Object] << :find_method # prevent stack overflow
  INSTANCE_METHOD_BLACKLIST[:Object] << :gem # funny testing stuff w/ Bundler

  if defined?(Pry)
    INSTANCE_METHOD_BLACKLIST[:Object] << :pry
    CLASS_METHOD_BLACKLIST[:Object] << :pry
  end

  class << self
    # Provided with a receiver, the desired result and possibly some
    # arguments, <tt>MethodFinder.find</tt> will list all methods that
    # produce the given result when called on the receiver with the
    # provided arguments.
    #
    #    MethodFinder.find(10, 1, 3)
    #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", "Integer#gcd", "Fixnum#modulo", "Numeric#remainder"]
    #    MethodFinder.find("abc","ABC")
    #    #=> ["String#swapcase", "String#swapcase!", "String#upcase", "String#upcase!"]
    #    MethodFinder.find(10, 100, 2)
    #    #=> ["Fixnum#**"]
    #    MethodFinder.find(['a','b','c'], ['A','B','C']) { |x| x.upcase }
    #    #=> ["Array#collect", "Array#collect!", "Enumerable#collect_concat", "Enumerable#flat_map", "Array#map", "Array#map!"]

    def find(obj, res, *args, &block)
      redirect_streams

      mets = methods_to_try(obj).select do |met|
        o = obj.dup rescue obj
        m = o.method(met)
        if m.arity <= args.size
          a = args.empty? && ARGS.has_key?(met) ? ARGS[met] : args
          m.call(*a, &block) == res rescue nil
        end
      end
      mets.map { |m| "#{obj.method(m).owner}##{m}" }
    ensure
      restore_streams
    end

    # Returns all currently defined modules and classes.
    def find_classes_and_modules
      constants = Object.constants.sort.map { |c| Object.const_get(c) }
      constants.select { |c| c.class == Class || c.class == Module}
    end

    # Searches for a given name within a class. The first parameter
    # can either be a class object, a symbol or a string whereas the
    # optional second parameter can be a string or a regular
    # expression:
    #
    #    MethodFinder.find_in_class_or_module('Array', 'shuff')
    #    #=> [:shuffle, :shuffle!]
    #    MethodFinder.find_in_class_or_module(Float, /^to/)
    #    #=> [:to_f, :to_i, :to_int, :to_r, :to_s]
    #
    # If the second parameter is omitted, all methods of the class or
    # module will be returned.
    #
    #    MethodFinder.find_in_class_or_module(Math)
    #    #=> [:acos, :acosh, :asin ... :tanh]

    def find_in_class_or_module(c, pattern=/./)
      cs = Object.const_get(c.to_s)
      class_methods = cs.methods(false) rescue []
      instance_methods = cs.instance_methods(false)
      all_methods = class_methods + instance_methods
      all_methods.grep(/#{pattern}/).sort
    end

    # Returns a list of candidate methods for a given object. Added by Jan Lelis.
    def methods_to_try(obj)
      ret = obj.methods
      blacklist = obj.is_a?(Module) ? CLASS_METHOD_BLACKLIST : INSTANCE_METHOD_BLACKLIST
      klass = obj.is_a?(Module) ? obj : obj.class

      klass.ancestors.each { |ancestor| ret -= blacklist[ancestor.to_s.intern] }

      ret.sort
    end

    # :nodoc:
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
