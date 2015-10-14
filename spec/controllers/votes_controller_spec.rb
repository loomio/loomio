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
    let(:vote) { Vote.new(motion: motion, user: user, position: 'yes') }

    it "flashes a motion closed message when the motion is closed" do
      motion.update_attribute :closed_at, Date.yesterday
      post :create, motion_id: motion.id, vote: { position: 'yes' }
      expect(flash[:notice]).to match(/motion has already closed/)
    end

    it 'calls MotionService::cast_vote' do
      VoteService.should_receive :create
      post :create, {motion_id: motion.id, vote: {position: 'yes'}}
    end

    it "assigns flash and redirects to discussion" do
      post :create, {motion_id: motion.id, vote: {position: 'yes'}}

      expect(flash[:success]).to match(/Position submitted/)
      response.should redirect_to motion.discussion
    end
  end
end
