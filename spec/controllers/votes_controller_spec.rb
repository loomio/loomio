require 'spec_helper'

describe VotesController do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }

  before :each do
    group.add_member!(user)
    sign_in user
  end

  describe "casting a vote" do
    it 'requires the user can vote' do
      VotesController.any_instance.should_receive(:require_user_can_vote)
      post :create, motion_id: motion.id, vote: {position: 'yes'}
    end

    it 'saves the vote' do
      vote = double(:vote).as_null_object
      vote.should_receive(:save)
      Vote.stub(:new).and_return(vote)
      post :create, motion_id: motion.id, vote: {position: 'yes'}
    end

    it "assigns flash and redirects to motion" do
      post :create, motion_id: motion.id, vote: {position: 'yes'}

      flash[:success].should =~ /Position submitted/
      response.should redirect_to motion
    end
  end

  describe "casting a 'block' vote" do
    it "fires motion_blocked event" do
      Events::MotionBlocked.should_receive(:publish!)
      post :create, motion_id: motion.id, vote: { position: 'block' }
    end
  end
end
