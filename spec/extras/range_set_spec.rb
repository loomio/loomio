require_relative '../../app/extras/range_set.rb'
require 'byebug'
require 'rails_helper'

describe RangeSet do
  it 'detects overlaps' do
    expect(RangeSet.overlaps?([1,1], [1,1])).to be true
    expect(RangeSet.overlaps?([1,2], [2,2])).to be true
    expect(RangeSet.overlaps?([1,2], [2,3])).to be true
    expect(RangeSet.overlaps?([2,3], [1,2])).to be true
    expect(RangeSet.overlaps?([2,2], [1,2])).to be true
    expect(RangeSet.overlaps?([1,3], [2,2])).to be true
    expect(RangeSet.overlaps?([2,2], [1,3])).to be true
    expect(RangeSet.overlaps?([2,2], [1,1])).to be false
    expect(RangeSet.overlaps?([1,1], [2,2])).to be false
  end

  it 'subtracts range from range' do
    expect(RangeSet.subtract_range([1,2], [])   ).to eq [[1,2]]
    expect(RangeSet.subtract_range([1,2], [3,4])).to eq [[1,2]]
    expect(RangeSet.subtract_range([1,2], [1,2])).to eq []
    expect(RangeSet.subtract_range([1,2], [1,1])).to eq [[2,2]]
    expect(RangeSet.subtract_range([1,2], [2,2])).to eq [[1,1]]
    expect(RangeSet.subtract_range([1,3], [2,2])).to eq [[1,1],[3,3]]
  end

  it 'subtracts ranges from ranges' do
    expect(RangeSet.subtract_ranges([[1,1]], [[1,1]])).to eq []
    expect(RangeSet.subtract_ranges([[1,2],[4,8]], [[1,1], [4,4]])).to eq [[2,2], [5,8]]
    expect(RangeSet.subtract_ranges([[1,2],[4,8]], [[5,6]])).to eq [[1,2], [4,4], [7,8]]
    expect(RangeSet.subtract_ranges([[1,2],[4,8]], [[5,6], [7,8]])).to eq [[1,2], [4,4]]
    ranges = [[1, 231]]
    read_ranges = [[1, 54], [62, 63], [65, 65], [67, 68], [76, 77], [79, 80], [85, 86], [89, 91], [97, 97], [100, 100], [112, 112], [115, 115], [120, 120], [126, 126], [134, 134], [137, 138], [141, 155], [167, 180], [184, 185], [187, 187], [192, 210], [219, 231]]
    expected_result = [[55, 61], [64, 64], [66, 66], [69, 75], [78, 78], [81, 84], [87, 88], [92, 96], [98, 99], [101, 111], [113, 114], [116, 119], [121, 125], [127, 133], [135, 136], [139, 140], [156, 166], [181, 183], [186, 186], [188, 191], [211, 218]]
    expect(RangeSet.subtract_ranges(ranges, read_ranges)).to eq expected_result

    ranges = [[1, 5], [10,20]]
    read_ranges = [[1,1], [3,5], [11,14],[18,19]]
    expected_result = [[2,2],[10,10],[15,17],[20,20]]
    expect(RangeSet.subtract_ranges(ranges, read_ranges)).to eq expected_result

    ranges = [[1, 5]]
    read_ranges = [[6,6]]
    expected_result = [[1,5]]
    expect(RangeSet.subtract_ranges(ranges, read_ranges)).to eq expected_result
  end

  it 'reduces to minimal sets' do
    expect(RangeSet.reduce([]))            .to eq []
    expect(RangeSet.reduce([[1,1]]))       .to eq [[1,1]]
    expect(RangeSet.reduce([[1,1], [2,2]])).to eq [[1,2]]
    expect(RangeSet.reduce([[1,2], [2,2]])).to eq [[1,2]]
    expect(RangeSet.reduce([[1,2], [1,1]])).to eq [[1,2]]
    expect(RangeSet.reduce([[2,2], [1,1]])).to eq [[1,2]]
    expect(RangeSet.reduce([[1,2], [2,3]])).to eq [[1,3]]
    expect(RangeSet.reduce([[1,2], [4,5]])).to eq [[1,2],[4,5]]
    expect(RangeSet.reduce([[1,2], [3,4], [5,6]])).to eq [[1,6]]
  end

  it 'creates_ranges_from_list' do
    expect(RangeSet.ranges_from_list([1])).to eq [[1,1]]
    expect(RangeSet.ranges_from_list([2])).to eq [[2,2]]
    expect(RangeSet.ranges_from_list([1,2])).to eq [[1,2]]
    expect(RangeSet.ranges_from_list([1,3])).to eq [[1,1], [3,3]]
    expect(RangeSet.ranges_from_list([1,2,3,5,6,7])).to eq [[1,3], [5,7]]
  end
end
