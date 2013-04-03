 require 'spec_helper'

describe MotionsHelper do
  describe "display_vote_buttons?(motion)" do
    before do
      @user = stub :user
      @motion = mock_model(Motion)
      @motion.stub(:voting?).and_return(true)
      @motion.stub(:user_has_voted?).and_return(false)
      @motion.stub_chain(:group, :users_include?).and_return(true)
    end
    context "motion closed" do
      before { @motion.stub(:voting?).and_return(false) }
      it "returns false" do
        display_vote_buttons?(@motion, @user).should == false
      end
    end
    context "user has voted" do
      before { @motion.stub(:user_has_voted?).and_return(true) }
      it "returns false" do
        display_vote_buttons?(@motion, @user).should == false
      end
    end
    context "user does not belong to the group" do
      before { @motion.stub_chain(:group, :users_include?).and_return(false)}
      it "returns false" do
        display_vote_buttons?(@motion, @user).should == false
      end
    end
  end
end
