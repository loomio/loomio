require 'rails_helper'

describe MotionsHelper do
  describe "display_vote_buttons?(motion, user)" do
    before do
      @user = double :user
      @motion = mock_model(Motion)
      @allow(motion).to receive(:voting?).and_return(true)
      @allow(motion).to receive(:user_has_voted?).and_return(false)
      @motion.stub_chain(:group, :users_include?).and_return(true)
    end
    context "motion closed" do
      before { @allow(motion).to receive(:voting?).and_return(false) }
      it "returns false" do
        expect(display_vote_buttons?(@motion, @user)).to be false
      end
    end
    context "user has voted" do
      before { @allow(motion).to receive(:user_has_voted?).and_return(true) }
      it "returns false" do
        expect(display_vote_buttons?(@motion, @user)).to be false
      end
    end
  end
  describe "time_select_options" do
    it "should include all hour times" do
      result = helper.time_select_options
      result.should include(["12 am", "00:00"])
      result.should include([" 2 am", "02:00"])
      result.should include(["12 pm", "12:00"])
      result.should include(["11 pm", "23:00"])
    end
  end
end
