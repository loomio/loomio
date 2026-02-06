require 'test_helper'

class RangeSetTest < ActiveSupport::TestCase
  test "detects overlaps" do
    assert RangeSet.overlaps?([1,1], [1,1])
    assert RangeSet.overlaps?([1,2], [2,2])
    assert RangeSet.overlaps?([1,2], [2,3])
    assert RangeSet.overlaps?([2,3], [1,2])
    assert RangeSet.overlaps?([2,2], [1,2])
    assert RangeSet.overlaps?([1,3], [2,2])
    assert RangeSet.overlaps?([2,2], [1,3])
    refute RangeSet.overlaps?([2,2], [1,1])
    refute RangeSet.overlaps?([1,1], [2,2])
  end

  test "subtracts range from range" do
    assert_equal [[1,2]],          RangeSet.subtract_range([1,2], [])
    assert_equal [[1,2]],          RangeSet.subtract_range([1,2], [3,4])
    assert_equal [],               RangeSet.subtract_range([1,2], [1,2])
    assert_equal [[2,2]],          RangeSet.subtract_range([1,2], [1,1])
    assert_equal [[1,1]],          RangeSet.subtract_range([1,2], [2,2])
    assert_equal [[1,1],[3,3]],    RangeSet.subtract_range([1,3], [2,2])
  end

  test "subtracts ranges from ranges" do
    assert_equal [], RangeSet.subtract_ranges([[1,1]], [[1,1]])
    assert_equal [[2,2], [5,8]], RangeSet.subtract_ranges([[1,2],[4,8]], [[1,1], [4,4]])
    assert_equal [[1,2], [4,4], [7,8]], RangeSet.subtract_ranges([[1,2],[4,8]], [[5,6]])
    assert_equal [[1,2], [4,4]], RangeSet.subtract_ranges([[1,2],[4,8]], [[5,6], [7,8]])

    ranges = [[1, 231]]
    read_ranges = [[1, 54], [62, 63], [65, 65], [67, 68], [76, 77], [79, 80], [85, 86], [89, 91], [97, 97], [100, 100], [112, 112], [115, 115], [120, 120], [126, 126], [134, 134], [137, 138], [141, 155], [167, 180], [184, 185], [187, 187], [192, 210], [219, 231]]
    expected_result = [[55, 61], [64, 64], [66, 66], [69, 75], [78, 78], [81, 84], [87, 88], [92, 96], [98, 99], [101, 111], [113, 114], [116, 119], [121, 125], [127, 133], [135, 136], [139, 140], [156, 166], [181, 183], [186, 186], [188, 191], [211, 218]]
    assert_equal expected_result, RangeSet.subtract_ranges(ranges, read_ranges)

    ranges = [[1, 5], [10,20]]
    read_ranges = [[1,1], [3,5], [11,14], [18,19]]
    expected_result = [[2,2], [10,10], [15,17], [20,20]]
    assert_equal expected_result, RangeSet.subtract_ranges(ranges, read_ranges)
    assert_equal ranges, RangeSet.reduce(read_ranges.concat(expected_result))

    ranges = [[1, 433]]
    read_ranges = [[1, 388], [390, 390], [393, 394], [398, 399], [402, 402], [404, 405], [409, 409], [412, 412], [414, 414], [417, 417], [421, 421], [424, 424], [426, 426], [428, 428], [430, 431], [433, 433]]
    unread_ranges = RangeSet.subtract_ranges(ranges, read_ranges)
    assert_equal ranges, RangeSet.reduce(unread_ranges.concat(read_ranges))

    ranges = [[1, 5]]
    read_ranges = [[6,6]]
    expected_result = [[1,5]]
    assert_equal expected_result, RangeSet.subtract_ranges(ranges, read_ranges)
  end

  test "reduces to minimal sets" do
    assert_equal [],                RangeSet.reduce([])
    assert_equal [[1,1]],           RangeSet.reduce([[1,1]])
    assert_equal [[1,2]],           RangeSet.reduce([[1,1], [2,2]])
    assert_equal [[1,2]],           RangeSet.reduce([[1,2], [2,2]])
    assert_equal [[1,2]],           RangeSet.reduce([[1,2], [1,1]])
    assert_equal [[1,2]],           RangeSet.reduce([[2,2], [1,1]])
    assert_equal [[1,3]],           RangeSet.reduce([[1,2], [2,3]])
    assert_equal [[1,2],[4,5]],     RangeSet.reduce([[1,2], [4,5]])
    assert_equal [[1,6]],           RangeSet.reduce([[1,2], [3,4], [5,6]])
  end

  test "creates ranges from list" do
    assert_equal [[1,1]],           RangeSet.ranges_from_list([1])
    assert_equal [[2,2]],           RangeSet.ranges_from_list([2])
    assert_equal [[1,2]],           RangeSet.ranges_from_list([1,2])
    assert_equal [[1,1], [3,3]],    RangeSet.ranges_from_list([1,3])
    assert_equal [[1,3], [5,7]],    RangeSet.ranges_from_list([1,2,3,5,6,7])
  end
end
