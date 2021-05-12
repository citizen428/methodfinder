# frozen_string_literal: true

require 'methodfinder/version'
require 'stringio'

class Object
  # An alternative interface to the functionality of
  # <tt>MethodFinder.find</tt>. Also allows to test for state other
  # than the return value of the method.
  #
  #    %w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
  #    #=> ["Array#delete_at", "Array#slice!"]
  #    10.find_method { |n| n.unknown(3) == 1 }
  #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", ...]
  #
  # Inside <tt>find_method</tt>'s block, the receiver is available as
  # block argument and the special method <tt>unknown</tt> is used as
  # a placeholder for the desired method.
  #
  # <tt>find_method</tt> can be called without passing a block. This
  # is the same as calling <tt>MethodFinder.find</tt>.
  #
  #    10.find_method(1, 3)
  #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", ...]
  def find_method(*args, &block)
    return MethodFinder.find(self, *args) unless block_given?
    MethodFinder.find_unknown(self, &block)
  end
end

module MethodFinder
  # Default arguments for methods
  # :nodoc:
  ARGS = {
    cycle: [1] # prevent cycling forever
  }.freeze

  # Ignoring methods, e.g. { :Object => [:ri, :vim] }
  INSTANCE_METHOD_IGNORELIST = Hash.new { |h, k| h[k] = [] }
  # Ignoring class methods
  CLASS_METHOD_IGNORELIST = Hash.new { |h, k| h[k] = [] }

  INSTANCE_METHOD_IGNORELIST[:Object] << :find_method # prevent stack overflow
  INSTANCE_METHOD_IGNORELIST[:Object] << :gem # funny testing stuff w/ Bundler

  if defined?(Pry)
    INSTANCE_METHOD_IGNORELIST[:Object] << :pry
    CLASS_METHOD_IGNORELIST[:Object] << :pry
  end

  # true if METHOD_FINDER_DEBUG is truthy, false otherwise e.g.:
  #
  #   $ METHOD_FINDER_DEBUG=1     irb # true
  #   $ METHOD_FINDER_DEBUG=0     irb # false
  #   $ METHOD_FINDER_DEBUG=false irb # false
  #   $ METHOD_FINDER_DEBUG=      irb # false
  @debug = !ENV.fetch('METHOD_FINDER_DEBUG', '').match(/\A(0|false)?\z/i)

  # Checks whether or not debugging is currently enabled
  # :doc:
  def self.debug?
    @debug
  end

  # Toggles the debug mode
  def self.toggle_debug!
    @debug = !@debug
  end

  # Provided with a receiver, the desired result and possibly some
  # arguments, <tt>MethodFinder.find</tt> will list all methods that
  # produce the given result when called on the receiver with the
  # provided arguments.
  #
  #    MethodFinder.find(10, 1, 3)
  #    #=> ["Fixnum#%", "Fixnum#<=>", "Fixnum#>>", "Fixnum#[]", ...]
  #    MethodFinder.find("abc","ABC")
  #    #=> ["String#swapcase", "String#swapcase!", "String#upcase", ...]
  #    MethodFinder.find(10, 100, 2)
  #    #=> ["Fixnum#**"]
  #    MethodFinder.find(['a','b','c'], ['A','B','C']) { |x| x.upcase }
  #    #=> ["Array#collect", "Array#collect!", "Enumerable#collect_concat", ...]
  def self.find(obj, res, *args, &block)
    find_methods(obj) do |met|
      o = obj.dup rescue obj
      m = o.method(met)
      next unless m.arity <= args.size
      STDERR.puts(met) if debug?
      a = args.empty? && ARGS.key?(met) ? ARGS[met] : args
      m.call(*a, &block) == res rescue nil
    end
  end

  # Returns all currently defined modules and classes.
  def self.find_classes_and_modules
    with_redirected_streams do
      constants = Object.constants.sort.map { |c| Object.const_get(c) }
      constants.select { |c| c.class == Class || c.class == Module }
    end
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
  # :doc:
  def self.find_in_class_or_module(klass, pattern = /./)
    klasses = Object.const_get(klass.to_s)
    class_methods = klasses.methods(false) rescue []
    instance_methods = klasses.instance_methods(false)
    all_methods = class_methods + instance_methods
    all_methods.grep(/#{pattern}/).sort
  end

  # Returns a list of candidate methods for a given object. Added by Jan Lelis.
  def self.methods_to_try(obj)
    ret = obj.methods
    ignorelist = select_ignorelist(obj)
    klass = obj.is_a?(Module) ? obj : obj.class

    klass.ancestors.each { |ancestor| ret -= ignorelist[ancestor.to_s.intern] }
    ret.sort
  end
  private_class_method :methods_to_try

  # Used by Object.find_method
  # :nodoc:
  def self.find_unknown(obj, &block)
    find_methods(obj) do |met|
      STDERR.puts(met) if debug?
      obj.class.class_eval("alias :unknown #{met}", __FILE__, __LINE__)
      subject = obj.dup rescue obj # dup doesn't work for immutable types
      block.call(subject) rescue nil
    end
  end

  def self.find_methods(obj)
    with_redirected_streams do
      found = methods_to_try(obj).select { |met| yield(met) }
      found.map { |m| "#{obj.method(m).owner}##{m}" }
    end
  end
  private_class_method :find_methods

  def self.with_redirected_streams
    orig_stdout = $stdout
    orig_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new

    yield
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end
  private_class_method :with_redirected_streams

  def self.select_ignorelist(object)
    object.is_a?(Module) ? CLASS_METHOD_IGNORELIST : INSTANCE_METHOD_IGNORELIST
  end
  private_class_method :select_ignorelist
end
