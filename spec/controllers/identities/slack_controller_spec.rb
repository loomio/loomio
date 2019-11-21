require 'rails_helper'

describe Identities::SlackController do
  let(:user) { create :user }

  describe 'authorized' do
    let!(:group) { create :formal_group }
    let(:group_identity) { create :group_identity, group: group, identity: identity, slack_channel_id: "C123" }
    let(:identity) { create :slack_identity, user: nil }

    it 'renders the slack authorized page' do
      get :authorized
      expect(subject).to render_template('slack/authorized')
    end

    it 'spawns a user from the session' do
      session[:pending_identity_id] = identity.id
      expect { get :authorized, params: { slack: "test-#{group_identity.slack_channel_id}" } }.to change { User.count }.by(1)
      u = User.last
      expect(group.member_ids).to include u.id
    end

    it 'associates with the current user if one is already logged in' do
      sign_in user
      session[:pending_identity_id] = identity.id
      expect { get :authorized, params: { slack: "test-#{group_identity.slack_channel_id}" } }.to_not change { User.count }
      expect(group.member_ids).to include user.id
    end
  end

  # describe 'install' do
  #   let(:identity) { create :slack_identity, user: user }
  #
  #   it 'boots the app if a pending identity exists' do
  #     session[:pending_identity_id] = identity.id
  #     get :install
  #     expect(response).to render_template 'application/index'
  #   end
  #
  #   it 'redirects to oauth path if no identity can be found' do
  #     get :install
  #     expect(response).to_not render_template 'layouts/angular'
  #   end
  # end

  describe 'participate' do
    let(:group) { create :formal_group }
    let(:discussion) { create :discussion, group: group }
    let(:poll) { create :poll_proposal, discussion: discussion }
    let(:identity) { create :slack_identity, user: user, uid: "U123" }
    let(:dangling_identity) { create :slack_identity, user: nil, uid: "U123" }
    let(:payload) { {
      user: { id: identity.uid },
      callback_id: poll.id,
      token: ENV['SLACK_VERIFICATION_TOKEN'],
      actions: [{ name: poll.poll_options.first.name }],
      team: { id: 'T123', name: 'billsbarbies' }
    } }
    let(:payload_without_poll) { {
      user: { id: identity.uid },
      callback_id: 'notapoll',
      token: ENV['SLACK_VERIFICATION_TOKEN'],
      actions: [{ name: poll.poll_options.first.name }],
      team: { id: 'T123', name: 'billsbarbies' }
    } }
    let(:payload_without_user) { {
      user: { id: 'notauser' },
      callback_id: poll.id,
      token: ENV['SLACK_VERIFICATION_TOKEN'],
      actions: [{ name: poll.poll_options.first.name }],
      team: { id: 'T123', name: 'billsbarbies' }
    } }
    let(:bad_payload) { {
      user: { id: identity.uid },
      callback_id: poll.id,
      token: ENV['SLACK_VERIFICATION_TOKEN'],
      actions: [],
      team: {}
    } }
    let(:user) { create :user }
    let(:another_user) { create :user }

    it 'creates a stance' do
      group.add_member! user
      sign_in user
      expect { post :participate, params: { payload: payload.to_json } }.to change { poll.stances.count }.by(1)
      stance = Stance.last
      expect(stance.participant).to eq user
      expect(stance.poll_options).to include poll.poll_options.first
    end

    it 'adds the user to the group' do
      sign_in user
      expect { post :participate, params: { payload: payload.to_json } }.to change { poll.stances.count }.by(1)
      stance = Stance.last
      expect(stance.participant).to eq user
      expect(user.groups).to include poll.group
    end

    describe 'with verification token set' do
      before { ENV['SLACK_VERIFICATION_TOKEN'] = 'sometoken' }
      after  { ENV['SLACK_VERIFICATION_TOKEN'] = nil }

      it 'responds correctly when verification token is supplied' do
        payload[:token] = 'sometoken'
        expect { post :participate, params: { payload: payload.to_json } }.to change { poll.stances.count }.by(1)
        expect(response.status).to eq 200
      end

      it 'responds with bad request when no token is supplied' do
        payload[:token] = 'anothertoken'
        expect { post :participate, params: { payload: payload.to_json } }.to_not change { poll.stances.count }
        expect(response.status).to eq 400
      end
    end

    it 'responds when no poll is found' do
      expect { post :participate, params: { payload: payload_without_poll.to_json } }.to_not change { Stance.count }
      expect(response.status).to eq 200
      expect(response.body).to include "poll was not found"
    end

    it 'does not create an invalid stance' do
      group.add_member! user
      sign_in user
      expect { post :participate, params: { payload: bad_payload.to_json } }.to_not change { poll.stances.count }
      expect(response.status).to eq 200 # we still render out a message to slack, so this response must be 'OK'
    end

    it 'responds with a stance if poll is part of a group' do
      sign_in user
      expect { post :participate, params: { payload: payload.to_json } }.to change { poll.stances.count }.by(1)
      expect(user.reload.groups).to include poll.group
      expect(response.status).to eq 200
    end

    xit 'responds with an auth link if poll is not part of a group' do
      poll.update(discussion: nil, group: nil)
      sign_in user
      expect { post :participate, params: { payload: payload.to_json } }.to_not change { poll.stances.count }
      expect(response.status).to eq 200
    end

    it 'finds the identity associated with a user if it exists' do
      identity
      dangling_identity
      expect { post :participate, params: { payload: payload.to_json } }.to change { poll.stances.count }.by(1)
      expect(response.status).to eq 200
    end

    it 'responds with unauthorized message if no user is found' do
      expect { post :participate, params: { payload: payload_without_user.to_json } }.to_not change { poll.stances.count }
      expect(response.status).to eq 200
      expect(response.body).to include "authorize your slack account"
    end

    it 'responds with a message if the poll is closed' do
      poll.update(closed_at: 1.day.ago)
      expect { post :participate, params: { payload: payload.to_json } }.to_not change { poll.stances.count }
      expect(response.status).to eq 200
    end
  end

  describe 'initiate' do
    let(:initiate_params) { {
      text: "proposal let's get started",
      channel_id: group_identity.slack_channel_id,
      team_id: identity.slack_team_id,
      team_domain: "example"
    } }
    let(:group) { create :formal_group }
    let(:identity) { create :slack_identity, custom_fields: { slack_team_id: "T123" } }
    let(:group_identity) { create(:group_identity, group: group, identity: identity, custom_fields: {
      slack_channel_id: "C123",
      slack_channel_name: "channel"
    }) }

    it 'responds with a poll creation url when an associated group is found' do
      post :initiate, params: initiate_params
      expect(response.body).to match /Okay, let's do this/
    end

    it 'responds with help for a bad poll type' do
      initiate_params[:text] = "wark let's get started"
      post :initiate, params: initiate_params
      expect(response.body).to match /You can choose from the following/
    end

    it 'responds with an unknown channel message if a group is found in the slack team' do
      initiate_params[:channel_id] = "notachannel"
      post :initiate, params: initiate_params
      expect(response.body).to match /it looks like there's not a loomio group associated/
    end

    it 'responds with an unauthorized message if no integration is found' do
      initiate_params[:team_id] = "notateam"
      post :initiate, params: initiate_params
      expect(response.body).to match /Just one more step/
      expect(response.body).to match slack_oauth_url
    end
  end

  describe 'create' do
    let(:user) { create :user }
    let(:invalid_oauth) { controller.stub(identity_params: {}) }
    let(:valid_oauth) { controller.stub(identity_params: identity_params) }
    let(:identity_params) { {
      access_token: 'token',
      email: "bob@builder.com",
      name: "Bob the BUilder",
      uid: "U123"
    } }
    before { controller.stub(complete_identity: nil) }

    it 'creates a new identity' do
      sign_in user
      valid_oauth
      expect { post :create, params: { code: 'code' } }.to change { user.identities.count }.by(1)
      expect(response).to redirect_to dashboard_path
    end

    it 'redirects to the session back_to if present' do
      valid_oauth
      session[:back_to] = 'http://example.com'
      post :create, params: { code: 'code' }
      expect(response).to redirect_to 'http://example.com'
    end

    it 'assigns a new identity to the session if an existing user cannot be found' do
      valid_oauth
      expect { post :create, params: { code: 'code' } }.to change { Identities::Base.count }.by(1)
      i = Identities::Base.last
      expect(i.name).to include identity_params[:name]
      expect(i.email).to include identity_params[:email]
      expect(session[:pending_identity_id]).to eq i.id
    end

    it 'associates the current user if already logged in' do
      sign_in user
      valid_oauth
      expect { post :create, params: { code: 'code' } }.to_not change { User.count }
      expect(controller.current_user).to eq user
      expect(Identities::Base.last.user).to eq user
      expect(response.status).to redirect_to dashboard_path
    end

    it 'associates a user by email if one is found' do
      valid_oauth
      existing = create(:user, email: identity_params[:email])
      expect(controller).to receive(:sign_in).with(existing)
      expect { post :create, params: { code: 'code' } }.to_not change { User.count }
      expect(response.status).to redirect_to dashboard_path
    end

    it 'does not create an invalid identity for an existing user' do
      sign_in user
      invalid_oauth
      expect { post :create, params: { code: 'code' } }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end

    it 'does not create a new user if the identity is invalid' do
      invalid_oauth
      expect { post :create, params: { code: 'code' } }.to_not change { User.count }
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
      controller.request.env['HTTP_REFERER'] = referrer
      delete :destroy
      expect(response).to redirect_to referrer
    end

    it 'does nothing if no identity is present' do
      sign_in user
      expect { delete :destroy }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end

    it 'does nothing for logged out users' do
      expect { delete :destroy }.to_not change { user.identities.count }
      expect(response.status).to eq 400
    end
  end
end
