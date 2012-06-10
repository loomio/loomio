require 'spec_helper'

describe DiscussionsHelper do
  describe "link_to_discussion" do
    before do
      @group = mock_model(Group, name: "Little group", parent: false)
      @discussion = mock_model(Discussion, group: @group)
    end
    it "contains discussion link" do
      helper.link_to_discussion(@discussion).should
        match("discussions/#{@discussion.id}")
    end
    it "does not contain group link" do
      helper.link_to_discussion(@discussion).should_not
        match("groups/#{@group.id}")
    end
    context "discussion belongs to a subgroup" do
      it "contains group link" do
        group = mock_model(Group, name: "Little group", parent: true)
        discussion = mock_model(Discussion, group: group)
        helper.link_to_discussion(discussion).should
          match("groups/#{group.id}")
      end
    end
  end
end

