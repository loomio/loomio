require 'rails_helper'

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

    it "flashes a motion closed message when the motion is closed" do 
      motion.update_attribute :closed_at, Date.yesterday
      post :create, motion_id: motion.id, vote: { position: 'yes' }   
      
      flash[:notice].should =~ /motion has already closed/   
    end

    it "flashes a permission denied message when the user does not have permission" do
      other_user = create :user
      sign_in other_user
      post :create, motion_id: motion.id, vote: { position: 'yes' }

      flash[:notice].should =~ /You do not have permission/
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
