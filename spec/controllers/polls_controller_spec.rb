
require 'rails_helper'

describe PollsController do
  let(:user) { create :user }
  let(:group) { create :group, is_visible_to_public: true }
  let(:discussion) { create :discussion, private: false, group: group }
  let(:poll) { create :poll, group: group, author: user }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:identity) { create :facebook_identity, user: user }
  let(:community) { create :facebook_community, identity: identity, poll_id: poll.id, identifier: "fb_one" }
  let(:another_community) { create :facebook_community, identifier: "fb_two" }
  let(:another_poll) { create :poll }
  let(:closed_poll) { create :poll, author: user, closed_at: 1.day.ago }
  let(:received_email) { create :received_email }

  before do
    group.add_member!(user)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    PollService.create(poll: poll, actor: poll.author)
  end

  # describe 'show' do
  #   it 'sets metadata for public polls' do
  #     poll.update(anyone_can_participate: true)
  #     get :show, params: { key: poll.key }
  #     expect(assigns(:metadata)[:title]).to eq poll.title
  #   end
  #
  #   it 'does not set metadata for private polls' do
  #     get :show, params: { key: poll.key }
  #     expect(assigns(:metadata)[:title]).to be_nil
  #   end
  # end


  describe 'export' do
    it 'displays an html export' do
      sign_in user
      get :export, params: { key: poll.key }
      expect(response.status).to eq 200
      expect(response).to render_template('polls/export')
    end

    it 'displays a csv export' do
      sign_in user
      get :export, params: { key: poll.key }, format: :csv
      expect(response.status).to eq 200
      expect(response.body).to include poll.title
    end

    it 'does not show export to non-coordinators' do
      sign_in another_user
      get :export, params: { key: poll.key }
    end
  end

  describe 'unsubscribe' do
    it 'unsubscribes from a poll' do
      sign_in user
      expect { get :unsubscribe, params: { key: poll.key } }.to change { poll.unsubscribers.count }.by(1)
    end

    it 'does not remove unsubscriptions' do
      sign_in user
      PollUnsubscription.create(user: user, poll: poll)
      expect { get :unsubscribe, params: { key: poll.key } }.to_not change { poll.unsubscribers.count }
    end

    it 'can unsubscribe via unsubscribe token' do
      expect { get :unsubscribe, params: { key: poll.key, unsubscribe_token: user.unsubscribe_token } }.to change { poll.unsubscribers.count }.by(1)
    end
  end
end
