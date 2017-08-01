require 'rails_helper'

describe API::StancesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:poll) { create :poll, discussion: discussion }
  let(:proposal) { create :poll_proposal, discussion: discussion }
  let(:poll_option) { create :poll_option, poll: poll }
  let(:old_stance) { create :stance, poll: poll, participant: user, poll_options: [poll_option] }
  let(:discussion) { create :discussion, group: group }
  let(:group) { create :formal_group }
  let(:stance_params) {{
    poll_id: poll.id,
    stance_choices_attributes: [{poll_option_id: poll_option.id}],
    reason: "here is my stance"
  }}
  let(:visitor) { create :visitor, community: public_poll.community_of_type(:public) }
  let(:visitor_stance) { create :stance, participant: visitor, poll: public_poll }

  let(:public_poll) { create :poll, discussion: nil, anyone_can_participate: true }
  let(:public_poll_option) { create :poll_option, poll: public_poll }
  let(:visitor_stance_params) {{
    poll_id: public_poll.id,
    stance_choices_attributes: [{poll_option_id: public_poll_option.id}],
    visitor_attributes: { name: "Johnny Doe", email: "john@doe.ninja" }
  }}

  describe 'index' do
    before { group.add_member! user }

    let(:recent_stance) { create :stance, poll: poll, created_at: 1.day.ago, choice: [low_priority_option.name] }
    let(:old_stance) { create :stance, poll: poll, created_at: 5.days.ago, choice: [low_priority_option.name] }
    let(:high_priority_stance) { create :stance, poll: poll, choice: [high_priority_option.name] }
    let(:low_priority_stance) { create :stance, poll: poll, choice: [low_priority_option.name] }
    let(:high_priority_option) { create(:poll_option, poll: poll, priority: 0) }
    let(:low_priority_option) { create(:poll_option, poll: poll, priority: 10) }

    it 'can order by recency asc' do
      sign_in user
      recent_stance; old_stance
      get :index, poll_id: poll.id, order: :newest_first
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq recent_stance.id
      expect(json['stances'][1]['id']).to eq old_stance.id
    end

    it 'can order by recency desc' do
      sign_in user
      recent_stance; old_stance
      get :index, poll_id: poll.id, order: :oldest_first
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq old_stance.id
      expect(json['stances'][1]['id']).to eq recent_stance.id
    end

    it 'can order by priority asc' do
      sign_in user
      high_priority_stance; low_priority_stance
      get :index, poll_id: poll.id, order: :priority_first
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq high_priority_stance.id
      expect(json['stances'][1]['id']).to eq low_priority_stance.id
    end

    it 'can order by priority desc' do
      sign_in user
      high_priority_stance; low_priority_stance
      get :index, poll_id: poll.id, order: :priority_last
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq low_priority_stance.id
      expect(json['stances'][1]['id']).to eq high_priority_stance.id
    end

    it 'does not allow unauthorized users to get stances' do
      get :index, poll_id: poll.id
      expect(response.status).to eq 403
    end
  end

  describe 'create' do
    let(:group)      { create :guest_group }
    let(:another_user) { create :user, email: 'another_user@example.com', email_verified: false }
    let(:invitation) { create :invitation, recipient_email: 'user@example.com', group: group }
    let(:user)       { create :user, email: 'user@example.com', email_verified: false }
    let(:poll)       { create :poll, guest_group: group }
    let(:poll_option) { create :poll_option, poll: poll }
    let(:visitor_stance_params) {{
      poll_id: poll.id,
      stance_choices_attributes: [{poll_option_id: poll_option.id}],
      visitor_attributes: { name: "Johnny Doe, not logged in", email: "user@example.com" }
    }}

    # user with verified email = verified email
    # user with unverified email = unverififed email
    # not user with that email = unrecognised email

    describe 'personal invitation to verified email' do
      before do
        invitation
        user.update(email_verified: true)
      end

      it 'logged in as same email' do
        # create stance and add user to group
        sign_in user
        expect { post :create, stance: stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(user.reload.groups).to include group
      end

      it 'logged in as different email' do
        # user is logged in as someone else
        # show message they need to logout - changed to let them vote...
        sign_in another_user
        expect { post :create, stance: stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(another_user.reload.groups).to include group
      end

      it 'not logged in' do
        # create stance as unveified user and add to group
        # email link or destroy stance email
        expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { ActionMailer::Base.deliveries.size }.by 1

        participant = Stance.last.participant
        expect(participant.email).to eq 'user@example.com'
        expect(participant.name).to eq visitor_stance_params[:visitor_attributes][:name]
        expect(participant.email_verified).to be false
        expect(invitation.reload.accepted?).to be true
        expect(last_email.to).to eq ['user@example.com']
        expect(last_email_html_body).to include "claim the vote"
      end
    end

    describe 'personal invitation to unverified email' do
      before do
        invitation
        another_user.update(email_verified: false)
        user.update(email_verified: false)
      end

      it 'logged in as different email' do
        # crate stance as logged in user, add user to group
        sign_in another_user
        expect { post :create, stance: stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(another_user.reload.groups).to include group
        expect(poll.stances.first.participant).to eq another_user
      end

      it 'not logged in' do
        # user has opportunity to login beforehand
        # create stance and unverified user
        expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(poll.stances.first.participant.email_verified).to eq false
        expect(poll.stances.first.participant.email).to eq 'user@example.com'
        expect(poll.stances.first.participant).to_not eq user
        expect(poll.guest_group.members).to include(poll.stances.first.participant)
        expect(last_email.to).to eq ['user@example.com']
        expect(last_email_html_body).to include "verify"
      end
    end

    describe 'personal invitation to unrecognised email' do

      before do
        invitation
      end

      # it 'logged in as same email'
      it 'logged in as different email' do
        # crate stance as logged in user, add user to group
        sign_in another_user
        expect { post :create, stance: stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(another_user.reload.groups).to include group
        expect(poll.stances.first.participant).to eq another_user
      end

      it 'not logged in' do
        # create stance and unverified user -> send verify/login email
        # user has opportunity to login beforehand
        # create stance and unverified user
        expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(invitation.reload.accepted?).to be true
        expect(poll.stances.first.participant.email_verified).to eq false
        expect(poll.stances.first.participant.email).to eq 'user@example.com'
        expect(poll.guest_group.members).to include(poll.stances.first.participant)
        expect(last_email.to).to eq ['user@example.com']
        expect(last_email_html_body).to include "verify"
      end
    end

    describe 'mass invitation' do
      let(:invitation) { create :shareable_invitation, group: poll.guest_group, inviter: poll.author }

      before do
        invitation
        user
      end

      it 'logged in' do
        # add to group and create stance
        user.update(email_verified: true)
        sign_in user
        expect { post :create, stance: stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
        expect(Stance.last.participant).to eq user
        expect(poll.members).to include user
      end

      describe 'not logged in' do
        it 'user enters verified users email' do
          user.update(email_verified: true)
          # create stance and unverified user, send claim_or_destroy (only single vote claim)
          expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
          stance = Stance.last
          expect(stance.participant.email_verified).to eq false
          expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]
          expect(poll.members).to include stance.participant
          expect(poll.members).to_not include User.verified.find_by(email: stance.participant.email)
          expect(last_email.to).to eq [stance.participant.email]
          expect(last_email_html_body).to include "claim the vote"
        end

        it 'user enters unverified users email' do
          # create stance and unverified user -> send verify/login email
          user.update(email_verified: false)
          expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
          stance = Stance.last
          expect(stance.participant.email_verified).to eq false
          expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]
          expect(poll.members).to include stance.participant
          expect(poll.members).to_not include User.verified.find_by(email: stance.participant.email)
          expect(last_email.to).to eq [stance.participant.email]
          expect(last_email_html_body).to include "verify your email"
        end

        it 'user enters unrecognised email' do
          # create stance and unverified user -> send verify/login email
          expect { post :create, stance: visitor_stance_params, invitation_token: invitation.token }.to change { Stance.count }.by(1)
          stance = Stance.last
          expect(stance.participant.email_verified).to eq false
          expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]
          expect(poll.members).to include stance.participant
          expect(poll.members).to_not include User.verified.find_by(email: stance.participant.email)
          expect(last_email.to).to eq [stance.participant.email]
          expect(last_email_html_body).to include "verify your email"
        end
      end
    end
  end

  describe "create as visitor without token" do
    it 'creates a new stance' do
      expect { post :create, stance: visitor_stance_params }.to change { Stance.count }.by(1)

      stance = Stance.last
      expect(stance.poll).to eq public_poll
      expect(stance.poll_options.first).to eq public_poll_option
      expect(stance.reason).to eq visitor_stance_params[:reason]
      expect(stance.latest).to eq true

      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['stances'].length).to eq 1
      expect(json['stances'][0]['id']).to eq stance.id
      expect(json['poll_options'].map { |o| o['name'] }).to include public_poll_option.name
    end

  end

  describe "create as logged in without token" do
    before { group.add_member! user }

    it 'creates a new stance' do
      sign_in user
      expect { post :create, stance: stance_params }.to change { Stance.count }.by(1)

      stance = Stance.last
      expect(stance.poll).to eq poll
      expect(stance.poll_options.first).to eq poll_option
      expect(stance.reason).to eq stance_params[:reason]
      expect(stance.latest).to eq true

      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['stances'].length).to eq 1
      expect(json['stances'][0]['id']).to eq stance.id
      expect(json['poll_options'].map { |o| o['name'] }).to include poll_option.name
    end

    # it 'can create a stance with a visitor' do
    #   expect { post :create, stance: visitor_stance_params }.to change { Stance.count }.by(1)
    #
    #   stance = Stance.last
    #   expect(stance.participant.name).to  eq visitor_stance_params[:visitor_attributes][:name]
    #   expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]
    #
    #   expect(response.status).to eq 200
    #   json = JSON.parse(response.body)
    #   names  = json['visitors'].map { |u| u['name'] }
    #   emails = json['visitors'].map { |u| u['email'] }
    #
    #   expect(names).to  include visitor_stance_params[:visitor_attributes][:name]
    #   expect(emails).to include visitor_stance_params[:visitor_attributes][:email]
    # end
    #
    # it 'does not create a stance with an incomplete visitor' do
    #   visitor_stance_params[:visitor_attributes] = {}
    #   expect { post :create, stance: visitor_stance_params }.to_not change { Stance.count }
    #   expect(response.status).to eq 422
    #
    #   json = JSON.parse(response.body)
    #   expect(json['errors']['participant_name']).to be_present
    # end
    #
    # it 'does not allow unauthorized visitors to create stances' do
    #   visitor_stance_params[:poll_id] = poll.id
    #   expect { post :create, stance: visitor_stance_params }.to_not change { Stance.count }
    #   expect(response.status).to eq 403
    # end
    #
    # it 'syncs to existing visitors if email matches' do
    #   expect(visitor_stance.latest).to eq true
    #   visitor_stance_params[:visitor_attributes][:email] = visitor_stance.participant.email
    #   expect { post :create, stance: visitor_stance_params }.to_not change { Stance.latest.count }
    #   expect(visitor_stance.reload.latest).to eq false
    #   expect(Stance.last.participant).to eq visitor_stance.participant
    #   expect(Stance.last.participant.name).to eq visitor_stance_params[:visitor_attributes][:name]
    # end

    it 'overwrites existing stances' do
      sign_in user
      old_stance
      expect { post :create, stance: stance_params }.to change { Stance.count }.by(1)
      expect(response.status).to eq 200
      expect(old_stance.reload.latest).to eq false
    end

    # it 'does not allow unauthorized visitors to create stances' do
    #   expect { post :create, stance: stance_params }.to_not change { Stance.count }
    #   expect(response.status).to eq 403
    # end

    it 'does not allow non members to create stances' do
      sign_in another_user
      expect { post :create, stance: stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 403
    end

    it 'does not allow creating an invalid stance' do
      sign_in user
      stance_params[:poll_id] = proposal.id
      stance_params[:stance_choices_attributes] = []
      expect { post :create, stance: stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 422
    end
  end
end
