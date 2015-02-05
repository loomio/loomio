require 'rails_helper'

describe SearchResult do
  let(:discussion) { create(:discussion) }
  let(:comment) { create(:comment, discussion: discussion) }
  let(:motion) { create(:motion, discussion: discussion) }

  it "stores a search result child of the discussion" do
    result = build(:search_result, discussion_id: discussion.id)
    expect(result.discussion).to be_a SearchResultChild
    expect(result.discussion.result).to eq discussion
  end

  it "responds to comments" do
    expect(build(:search_result, comments: [comment]).comments). to include comment
  end

  it "responds to motions" do
    expect(build(:search_result, motions: [motion]).motions). to include motion
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

