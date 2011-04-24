require 'minitest/autorun'
require 'methodfinder'

class TestMethodFinder < MiniTest::Unit::TestCase

  def test_finding_method_with_no_argument_or_block
    result = MethodFinder.find('a', 'A')
    assert result.include?(:capitalize)
    assert result.include?(:upcase)
  end

  def test_finding_method_with_an_argument_and_no_block
    result = MethodFinder.find(10,1,3)
    assert result.include?(:%)
    assert result.include?(:modulo)
  end

  def test_finding_method_with_a_block
    result = MethodFinder.find(%w(a b), %w(A B)) { |x| x.upcase }
    assert result.include?(:map)
    assert result.include?(:collect)
  end

  def test_block_interface
    assert_equal [:delete_at, :slice!],
    %w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
  end

  def test_instance_interface
    result = 'a'.find_method 'A'
    assert result.include?(:capitalize)
    assert result.include?(:upcase)
  end

  def test_instance_interface_with_params
    result = %w[a b c].find_method %w[a b], %w[c]
    assert result.include?(:-)
  end

  def test_find_classes_and_modules
    assert MethodFinder.find_classes_and_modules.include?(Array)
    assert MethodFinder.find_classes_and_modules.include?(Math)
  end

  def test_find_in_class_or_module
    if RUBY_VERSION.start_with?("1.9")
      res = [:shuffle, :shuffle!]
    else
      res = %w(shuffle shuffle!)
    end

    [Array, :Array, 'Array'].product(['shuff', /shuff/]).each do |c, pattern|
      assert_equal res,
      MethodFinder.find_in_class_or_module(c, pattern)
    end

    assert MethodFinder.find_in_class_or_module(Math, /sin/).include?(:sin)

    result = MethodFinder.find_in_class_or_module(:Float, /^to/)
    assert result.include?(:to_f)
    assert result.include?(:to_r)

    assert MethodFinder.find_in_class_or_module(Array).size > 10
  end

  def test_ignores_items_in_blacklist
    MethodFinder::INSTANCE_METHOD_BLACKLIST[:Object] << :flatten
    assert !MethodFinder.find([2,3,4], [2,3,4]).include?(:flatten)
  end
end
