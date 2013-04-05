require 'spec_helper'

describe ViewLogger do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  # describe "motion_viewed(motion, user)" do
  #   before { @motion = create(:motion) }

  #   it "creates a new motion_read_log" do
  #     ViewLogger.motion_viewed(@motion, user)
  #     MotionReadLog.count.should == 1
  #   end

  #   it "updates an existing motion_read_log" do
  #     time_now = Time.now
  #     Time.stub(now: time_now)
  #     @motion_read_log = mock_model(MotionReadLog)
  #     MotionReadLog.stub_chain(:where, :first).and_return(@motion_read_log)
  #     @motion_read_log.stub(:save!).and_return(true)
  #     @motion_read_log.should_receive(:update_attributes).
  #       with(hash_including(motion_last_viewed_at: time_now))
  #     ViewLogger.motion_viewed(@motion, user)
  #   end
  # end

  # describe "discussion_viewed(discussion, user)" do
  #   before { @discussion = create(:discussion, group: group) }

  #   it "creates a new discussion_read_log" do
  #     ViewLogger.discussion_viewed(@discussion, user)
  #     DiscussionReadLog.count.should == 1
  #   end

  #   it "updates an existing discussion_read_log" do
  #     time_now = Time.now
  #     Time.stub(now: time_now)
  #     discussion_read_log = mock_model(DiscussionReadLog)
  #     DiscussionReadLog.stub_chain(:where, :first).and_return(discussion_read_log)
  #     discussion_read_log.stub(:save!).and_return(true)
  #     discussion_read_log.should_receive(:update_attributes).
  #       with(hash_including(discussion_last_viewed_at: time_now))
  #     ViewLogger.discussion_viewed(@discussion, user)
  #   end

  #   it "updates the total views" do
  #     @discussion.should_receive(:update_total_views)
  #     ViewLogger.discussion_viewed(@discussion, user)
  #   end
  # end

  # describe "group_viewed(group, user)" do
  #   context "a membership exists" do
  #     before do
  #       @membership = create(:membership, group: group, user: user)
  #       user.stub(:group_membership).with(group).and_return(@membership)
  #       @membership.stub(:save!)
  #     end

  #     it "stores the current time in the membership" do
  #       @membership.should_receive(:group_last_viewed_at)
  #       ViewLogger.group_viewed(group, user)
  #     end
  #   end
  # end

  describe "#delete_all_logs_for(user)" do
    before do
      user1 = create(:user)
      @motion = create(:motion)
      @discussion = create(:discussion)
      ViewLogger.motion_viewed(@motion, user)
      ViewLogger.discussion_viewed(@discussion, user)
      ViewLogger.motion_viewed(@motion, user1)
      ViewLogger.discussion_viewed(@discussion, user1)
    end
    it "should remove all logs from the MotionReadLog" do
      ViewLogger.delete_all_logs_for(user.id)
      MotionReadLog.count.should == 1
    end
    it "should remove all logs from the DiscusionReadLog" do
      ViewLogger.delete_all_logs_for(user.id)
      DiscussionReadLog.count.should == 1
    end
  end

end
