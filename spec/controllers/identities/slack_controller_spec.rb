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
      expect(response.status).to eq 200 # we still render out a message to slack, so this response must be 'OK'
    end
  end

  describe 'create' do
    let(:user) { create :user }
    let(:invalid_oauth) { controller.stub(oauth_identity_params: {}) }
    let(:valid_oauth) { controller.stub(oauth_identity_params: oauth_identity_params) }
    let(:oauth_identity_params) { {
      access_token: 'token',
      email: "bob@builder.com",
      name: "Bob the BUilder",
      uid: "U123"
    } }
    before { controller.stub(complete_identity: nil) }

    it 'creates a new identity' do
      sign_in user
      valid_oauth
      expect { post :create, code: 'code' }.to change { user.identities.count }.by(1)
      expect(response).to redirect_to dashboard_path
    end

    it 'redirects to the session back_to if present' do
      valid_oauth
      session[:back_to] = 'http://example.com'
      post :create, code: 'code'
      expect(response).to redirect_to 'http://example.com'
    end

    it 'sets session with a pending identity id if one is not logged in' do
      valid_oauth
      expect { post :create, code: 'code' }.to change { Identities::Base.count }.by(1)
      i = Identities::Base.last
      expect(i.name).to eq oauth_identity_params[:name]
      expect(i.email).to eq oauth_identity_params[:email]
      expect(i.identity_type).to eq 'slack'
      expect(request.env['rack.session'][:pending_identity_id]).to eq i.id
    end

    it 'associates the identity with an existing user if there is an email match' do
      valid_oauth
      user = create(:user, email: oauth_identity_params[:email])
      expect { post :create, code: 'code' }.to_not change { User.count }
      expect(response).to redirect_to dashboard_path
      expect(Identities::Base.last.user).to eq user
    end

    it 'does not create an invalid identity for an existing user' do
      sign_in user
      invalid_oauth
      expect { post :create, code: 'code' }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end

    it 'does not create a new user if the identity is invalid' do
      invalid_oauth
      expect { post :create, code: 'code' }.to_not change { User.count }
      expect(response.status).to eq 400
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
