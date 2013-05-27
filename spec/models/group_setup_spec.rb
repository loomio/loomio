require 'spec_helper'

describe "GroupSetup" do
  let(:author) { create :user }
  let(:group) { create :group }
  let(:group_setup){ create :group_setup, group: group }

  describe "compose_group!(author)" do
    before do
      group_setup.compose_group!
    end

    it 'copies attributes from group_setup to group' do
      group.name.should == group_setup.group_name
      group.description.should == group_setup.group_description
      group.viewable_by.should == group_setup.viewable_by
      group.members_invitable_by.should == group_setup.members_invitable_by
    end
  end

  describe "compose_discussion" do
    before do
      group_setup.compose_discussion!(author, group)
    end

    it 'creates a new discussion from the group_setup and assigns it to the group' do
      discussion = group_setup.group.discussions.first
      discussion.title.should == group_setup.discussion_title
      discussion.description.should == group_setup.discussion_description
      discussion.group.should == group
      discussion.author.should == author
    end
  end

  describe "finish!(author)" do
    it "returns true if group and discussion created" do
      group_setup.finish!(author).should == true
    end

    it "returns false if group or discussion are not created" do
      group_setup.stub(:compose_group!).and_return(false)
      group_setup.finish!(author).should == false
    end
  end
end