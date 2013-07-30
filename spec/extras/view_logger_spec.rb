require 'spec_helper'

describe ViewLogger do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  describe "motion_viewed(motion, user)" do
    before { @motion = create(:motion) }

    it "creates a new motion_read_log" do
      ViewLogger.motion_viewed(@motion, user)
      MotionReadLog.count.should == 1
    end

    it "updates an existing motion_read_log" do
      time_now = Time.now
      Time.stub(now: time_now)
      @motion_read_log = mock_model(MotionReadLog)
      MotionReadLog.stub_chain(:where, :first).and_return(@motion_read_log)
      @motion_read_log.stub(:save!).and_return(true)
      @motion_read_log.should_receive(:update_attributes).
        with(hash_including(motion_last_viewed_at: time_now))
      ViewLogger.motion_viewed(@motion, user)
    end
  end
end
