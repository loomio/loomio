require 'spec_helper'

describe "GroupSetup" do
  let(:group_setup){ create :group_setup }

  describe "compose_group" do
    before do
      group_setup.compose_group
    end

    it 'builds a group on self' do
      group_setup.group.should be_present
    end

    it 'copies attributes from group_setup to group' do
      group = group_setup.group
      group.name.should == group_setup.group_name
      group.description.should == group_setup.group_description
      group.viewable_by.should == group_setup.viewable_by
      group.members_invitable_by.should == group_setup.members_invitable_by
    end
  end

  describe "compose_discussion" do
    before do
      group_setup.compose_discussion
    end

    it 'builds a discussion on self' do
      group_setup.discussion.should be_present
    end

    it 'copies attributes from group_setup to group' do
      discussion = group_setup.discussion
      discussion.title.should == group_setup.discussion_title
      discussion.description.should == group_setup.discussion_description
    end
  end

  describe "compose_motion" do
    before do
      group_setup.compose_motion
    end

    it 'builds a motion on self' do
      group_setup.motion.should be_present
    end

    it 'copies attributes from group_setup to group' do
      motion = group_setup.motion
      motion.name.should == group_setup.motion_title
      motion.description.should == group_setup.motion_description
      motion.close_date.should == group_setup.close_date
    end
  end
end
