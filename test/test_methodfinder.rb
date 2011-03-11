require 'minitest/autorun'
require 'methodfinder'

class TestMethodFinder < MiniTest::Unit::TestCase

  def test_finding_method_with_no_argument_or_block
    assert_equal [:capitalize, :capitalize!, :swapcase, :swapcase!, :upcase, :upcase!],
    MethodFinder.find('a', 'A')
  end

  def test_finding_method_with_an_argument_and_no_block
    assert_equal [:%, :<=>, :>>, :[], :gcd, :modulo, :remainder],
    MethodFinder.find(10,1,3)
  end

  def test_finding_method_with_a_block
    assert_equal [:collect, :collect!, :collect_concat, :flat_map, :map, :map!],
    MethodFinder.find(%w(a b), %w(A B)) { |x| x.upcase }
  end

end
