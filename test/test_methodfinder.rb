require 'minitest/autorun'
require 'methodfinder'

class TestMethodFinder < MiniTest::Unit::TestCase

  def test_finding_method_with_no_argument_or_block
    result = MethodFinder.find('a', 'A')
    assert true, result.include?(:capitalize)
    assert true, result.include?(:upcase)
  end

  def test_finding_method_with_an_argument_and_no_block
    result = MethodFinder.find(10,1,3)
    assert true, result.include?(:%)
    assert true, result.include?(:modulo)
  end

  def test_finding_method_with_a_block
    result = MethodFinder.find(%w(a b), %w(A B)) { |x| x.upcase }
    assert true, result.include?(:map)
    assert true, result.include?(:collect)
  end

  def test_block_interface
    assert_equal [:delete_at, :slice!],
    %w[a b c].find_method { |a| a.unknown(1) ; a == %w[a c] }
  end

  def test_find_classes_and_modules
    assert true, MethodFinder.find_classes_and_modules.include?(Array)
    assert true, MethodFinder.find_classes_and_modules.include?(Math)
  end

  def test_find_in_class_or_module
    [Array, :Array, 'Array'].product(['shuff', /shuff/]).each do |c, pattern|
      assert_equal [:shuffle, :shuffle!],
      MethodFinder.find_in_class_or_module(c, pattern)
    end

    assert true,
    MethodFinder.find_in_class_or_module(Math, /sin/).include?(:sin)

    result = MethodFinder.find_in_class_or_module(:Float, /^to/)
    assert true, result.include?(:to_f)
    assert true, result.include?(:to_r)

    assert true, MethodFinder.find_in_class_or_module(Array).size > 10
  end

  def test_ignores_items_in_blacklisdt
    MethodFinder::INSTANCE_METHOD_BLACKLIST[:Object] << :flatten
    assert true, !MethodFinder.find( [2,3,4], [2,3,4] ).include?(:flatten)
  end
end
