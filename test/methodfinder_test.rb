require 'minitest/autorun'
require 'methodfinder'

class TestMethodFinder < Minitest::Test
  def test_finding_method_with_no_argument_or_block
    result = MethodFinder.find('a', 'A')
    assert result.include?('String#capitalize')
    assert result.include?('String#upcase')
  end

  def test_finding_method_with_an_argument_and_no_block
    result = MethodFinder.find('twothreefour', 'three', 3, 5)
    assert result.include?('String#slice')
    assert result.include?('String#slice!')
  end

  def test_finding_method_with_a_block
    result = MethodFinder.find(%w[a b], %w[A B], &:upcase)
    assert result.include?('Array#map')
    assert result.include?('Array#collect')
  end

  def test_block_interface
    assert_equal(
      ['Array#delete_at', 'Array#slice!'],
      %w[a b c].find_method { |a| a.unknown(1); a == %w[a c] }
    )
  end

  def test_instance_interface
    result = 'a'.find_method('A')
    assert result.include?('String#capitalize')
    assert result.include?('String#upcase')
  end

  def test_instance_interface_with_params
    # ignoring method for Rubinius
    if Object.const_defined?(:RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      MethodFinder::INSTANCE_METHOD_IGNORELIST[:Array] << :new_reserved
    end

    result = %w[a b c].find_method(%w[a b], %w[c])
    assert result.include?('Array#-')
  end

  def test_find_classes_and_modules
    assert MethodFinder.find_classes_and_modules.include?(Array)
    assert MethodFinder.find_classes_and_modules.include?(Math)
  end

  def test_find_in_class_or_module
    [Array, :Array, 'Array'].product(['pop', /pop/]).each do |c, pattern|
      assert MethodFinder.find_in_class_or_module(c, pattern).include?(:pop)
    end

    assert MethodFinder.find_in_class_or_module(Math, /sin/).include?(:sin)

    result = MethodFinder.find_in_class_or_module(:Float, /^to/)
    assert result.include?(:to_f)

    assert MethodFinder.find_in_class_or_module(Array).size > 10
  end

  def test_ignores_items_in_ignorelist
    assert MethodFinder.find([[2, 3, 4]], [2, 3, 4]).include?('Array#flatten')
    MethodFinder::INSTANCE_METHOD_IGNORELIST[:Object] << :flatten
    assert !MethodFinder.find([[2, 3, 4]], [2, 3, 4]).include?('Array#flatten')
  end

  # See: https://github.com/citizen428/methodfinder/issues/10
  def test_it_works_with_hashes
    receiver = { foo: 'bar' }
    argument = { baz: 'quux' }
    result   = { foo: 'bar', baz: 'quux' }

    assert_equal(
      ['Hash#merge', 'Hash#merge!', 'Hash#update'],
      receiver.find_method(result, argument)
    )
  end

  def test_debugging
    refute MethodFinder.debug?
    MethodFinder.toggle_debug!
    assert MethodFinder.debug?
    MethodFinder.toggle_debug!
    refute MethodFinder.debug?
  end
end
