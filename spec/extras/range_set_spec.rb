require_relative '../../app/extras/range_set.rb'
require 'byebug'
# require 'rails_helper'

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
