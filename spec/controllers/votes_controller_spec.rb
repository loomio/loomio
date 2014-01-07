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
    let(:vote) { Vote.new(motion: motion, user: user, position: 'yes') }
    it 'requires the user can vote' do
      VotesController.any_instance.should_receive(:require_user_can_vote)
      post :create, motion_id: motion.id, vote: {position: 'yes'}
    end

    it 'casts the vote with VoteService' do
      VoteService.should_receive(:cast).and_return(true)
      post :create, motion_id: motion.id, vote: {position: 'yes'}
    end

    it "assigns flash and redirects to motion" do
      post :create, motion_id: motion.id, vote: {position: 'yes'}

      flash[:success].should =~ /Position submitted/
      response.should redirect_to discussion
    end
  end
end
