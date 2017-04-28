require 'rails_helper'

describe Identities::SlackController do
  describe 'authorized' do
    subject { get :authorized }
    it 'renders the slack authorized page' do
      expect(subject).to render_template('slack/authorized')
    end
  end

  describe 'participate' do
    let(:group) { create :group }
    let(:discussion) { create :discussion, group: group }
    let(:poll) { create :poll_proposal, discussion: discussion }
    let(:identity) { create :slack_identity }
    let(:payload) { {
      user: { id: identity.uid },
      callback_id: poll.id,
      actions: [{ name: poll.poll_options.first.name }]
    }.to_json }
    let(:bad_payload) { {
      user: { id: identity.uid },
      callback_id: poll.id,
      actions: []
    }.to_json }
    let(:user) { create :user }
    let(:another_user) { create :user }
    let(:identity) { create :slack_identity, user: user, uid: "abcd" }
    before { group.add_member! user }

    it 'creates a stance' do
      sign_in user
      expect { post :participate, payload: payload }.to change { poll.stances.count }.by(1)
      stance = Stance.last
      expect(stance.participant).to eq user
      expect(stance.poll_options).to include poll.poll_options.first
    end

    it 'does not create an invalid stance' do
      sign_in user
      expect { post :participate, payload: bad_payload }.to_not change { poll.stances.count }
      expect(response.status).to eq 403
    end
  end

  describe 'create' do
    it 'creates a new identity' do
    end

    it 'also creates a new user if one is not logged in' do
    end

    it 'does not create an invalid identity for an existing user' do
    end

    it 'does not create a new user if the identity is invalid' do
    end
  end

  describe 'destroy' do
    let(:user) { create :user }
    let(:identity) { create :slack_identity, user: user }
    let(:another_user) { create :user }
    let(:another_identity) { create :slack_identity, user: another_user }
    let(:referrer) { 'http://example.com' }

    it 'destroys an identity' do
      sign_in user
      identity
      expect { delete :destroy }.to change { user.identities.count }.by(-1)
      expect(response).to redirect_to root_path
    end

    it 'redirects to the referrer if present' do
      sign_in user
      identity
      controller.request.stub referrer: referrer
      delete :destroy
      expect(response).to redirect_to referrer
    end

    it 'does nothing if no identity is present' do
      sign_in user
      expect { delete :destroy }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end

    it 'does nothing for visitors' do
      expect { delete :destroy }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end
  end
end
