require 'spec_helper'

describe MotionReadLog do
  before :each do
    @user = User.make
    @user.save
    @motion = create_motion
    @motion.group.add_member!(@user)
  end

  context "a new motion_read_log" do
    subject do
      @log = Motion_read_log.new
      @log.valid?
      @log

      it "must have a vote_activity_when_last_read, discussion_activity_when_last_read, user and a motion" do
        @log.should have(1).errors_on(:vote_activity_when_last_read)
        @log.should have(1).errors_on(:discussion_activity_when_last_read)
        @log.should have(1).errors_on(:user_id)
        @log.should have(1).errors_on(:motion_id)
      end
    end
  end
end
