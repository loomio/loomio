require 'test_helper'

class VoteWeightTest < ActiveSupport::TestCase
  test "parse! accepts weights the client accepts and rounds to the stored precision" do
    assert_equal BigDecimal('0'), VoteWeight.parse!('0')
    assert_equal BigDecimal('2.33'), VoteWeight.parse!(' 2.33 ')
    assert_equal BigDecimal('3'), VoteWeight.parse!(3)
    assert_equal BigDecimal('0.001'), VoteWeight.parse!('0.0006')
    assert_equal BigDecimal('999999999.999'), VoteWeight.parse!('999999999.999')
  end

  test "parse! rejects weights that cannot be stored" do
    ['-1', 'abc', '', nil, '1e3', '01', '1000000000', '999999999.9996'].each do |value|
      assert_raises(VoteWeight::Invalid, value.inspect) { VoteWeight.parse!(value) }
    end
  end
end
