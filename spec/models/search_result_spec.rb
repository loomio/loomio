require 'rails_helper'

describe SearchResult do
  let(:discussion) { create(:discussion) }
  let(:comment) { create(:comment, discussion: discussion) }
  let(:motion) { create(:motion, discussion: discussion) }

  it "can set models" do
    result = build(:search_result, discussion: discussion, motion: motion, comment: comment)
    expect(result.discussion).to eq discussion
    expect(result.motion).to eq motion
    expect(result.comment).to eq comment
  end

  it "can set blurbs" do
    result = build(:search_result, discussion_blurb: 'dblurb', motion_blurb: 'mblurb', comment_blurb: 'cblurb')
    expect(result.discussion_blurb).to eq 'dblurb'
    expect(result.motion_blurb).to eq 'mblurb'
    expect(result.comment_blurb).to eq 'cblurb'
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
