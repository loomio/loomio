require 'spec_helper'

describe MotionActivityReadLog do
  before :each do
    @user = User.make
    @user.save
    @motion = create_motion
    @motion.group.add_member!(@user)
  end

  context "a new motion_activity_read_log" do
    subject do
      @log = Motion_activity_read_log.new
      @log.valid?
      @log

      it "must have a last_read_at, user and a motion" do
        @log.should have(1).errors_on(:last_read_at)
        @log.should have(1).errors_on(:user_id)
        @log.should have(1).errors_on(:motion_id)
      end
    end
  end
end
