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

  describe "compose_motion(author, discussion)" do
    before do
      @discussion = create(:discussion, group_id: group_setup.group.id)
      group_setup.compose_motion!(author, @discussion)
    end

    it "creates a new motion from the group_setup and assigns it to the group's discussion" do
      motion = group_setup.group.motions.first
      motion.name.should == group_setup.motion_title
      motion.description.should == group_setup.motion_description
      motion.close_at_date.should == group_setup.close_at_date
      motion.close_at_time.should == group_setup.close_at_time
      motion.close_at_time_zone == group_setup.close_at_time_zone
      motion.discussion.should == @discussion
      motion.author.should == author
    end
  end

  describe "#send_invitations(recipients)" do
    it "sends an email to each recipient in the list" do
      recipients = ["mad@waxfins.com", "tom@jerry@com"]
    end
  end

  describe "finish!(author)" do
    it "returns true if group, discussion and motion are all created" do
      group_setup.finish!(author).should == true
    end

    it "returns false if group or discussion or motion are not created" do
      group_setup.stub(:compose_motion!).and_return(false)
      group_setup.finish!(author).should == false
    end
  end

  describe "recipients" do
    it "parses the string members_list and returns a collection" do
    end
  end
end