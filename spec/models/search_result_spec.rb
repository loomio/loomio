require 'rails_helper'

describe SearchResult do
  let(:discussion) { create(:discussion) }
  let(:comment) { create(:comment) }

  it "responds to result" do
    expect(build(:search_result, result: discussion).result). to eq discussion
    expect(build(:search_result, result: comment).result). to eq comment
  end

  it "responds to query" do
    expect(build(:search_result, query: 'query').query). to eq 'query'
  end

  it "responds to priority" do
    expect(build(:search_result, priority: 10).priority). to eq 10
  end

  it "can read attributes for serialization" do
    search_result = build(:search_result, query: 'query')
    expect(search_result.read_attribute_for_serialization(:query)).to eq 'query'
  end

end

