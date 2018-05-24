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
  let(:public_poll) { create :poll, discussion: nil, anyone_can_participate: true }
  let(:public_poll_option) { create :poll_option, poll: public_poll }
  let(:visitor_stance_params) {{
    poll_id: public_poll.id,
    stance_choices_attributes: [{poll_option_id: public_poll_option.id}],
    visitor_attributes: { name: "Johnny Doe", email: "john@doe.ninja", legal_accepted: true }
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
      get :index, params: { poll_id: poll.id, order: :newest_first }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq recent_stance.id
      expect(json['stances'][1]['id']).to eq old_stance.id
    end

    it 'can order by recency desc' do
      sign_in user
      recent_stance; old_stance
      get :index, params: { poll_id: poll.id, order: :oldest_first }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq old_stance.id
      expect(json['stances'][1]['id']).to eq recent_stance.id
    end

    it 'does not reveal participant for other peoples votes' do
      my_stance    = create(:stance, participant: user, poll: poll)
      other_stance = create(:stance, poll: poll)
      poll.update(anonymous: true)
      sign_in user
      get :index, params: { poll_id: poll.id }

      json = JSON.parse(response.body)
      stance_ids = json['stances'].map { |s| s['id'] }
      user_ids   = json['users'].map   { |u| u['id'] }

      expect(stance_ids).to include my_stance.id
      expect(stance_ids).to include other_stance.id
      expect(user_ids).to include my_stance.participant_id
      expect(user_ids).to_not include other_stance.participant_id
    end

    it 'can order by priority asc' do
      sign_in user
      high_priority_stance; low_priority_stance
      get :index, params: { poll_id: poll.id, order: :priority_first }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq high_priority_stance.id
      expect(json['stances'][1]['id']).to eq low_priority_stance.id
    end

    it 'can order by priority desc' do
      sign_in user
      high_priority_stance; low_priority_stance
      get :index, params: { poll_id: poll.id, order: :priority_last }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)

      expect(json['stances'][0]['id']).to eq low_priority_stance.id
      expect(json['stances'][1]['id']).to eq high_priority_stance.id
    end

    it 'does not allow unauthorized users to get stances' do
      get :index, params: { poll_id: poll.id }
      expect(response.status).to eq 403
    end
  end

  describe do
    let(:unverified_user)       { create :user, email: 'user@example.com', email_verified: false }
    let(:user)                  { create :user, email: 'user@example.com', email_verified: true }
    let(:stance)                { create :stance, participant: unverified_user }

    describe 'unverified' do
      it 'lists unconfirmed stances' do
        sign_in user
        stance
        get :unverified
        expect(response.status).to eq 200
        expect(assigns(:stances)).to include stance
      end
    end

    describe 'verify' do
      it 'verifies unverified stances by verified email address' do
        sign_in user
        stance
        expect{post :verify, params: { id: stance.id }}.to change { user.stances.count }.by 1
        expect(response.status).to eq 200
        expect(assigns(:stance)).to eq stance
        expect(stance.reload.participant).to eq user
      end

      it 'cannot verify stances by another email address' do
        sign_in user
        stance.participant.update(email: 'notme@example.com')
        expect{post :verify, params: { id: stance.id }}.to_not change { user.stances.count }
        expect(response.status).to eq 403
      end

      it 'cannot verify stances already verified' do
        sign_in user
        stance.update(participant: user)
        expect{post :verify, params: { id: stance.id }}.to_not change { user.stances.count }
        expect(response.status).to eq 403
      end
    end

    describe 'destroy' do
      it 'destroys unverified stances' do
        sign_in user
        stance
        expect{post :destroy, params: { id: stance.id }}.to change { unverified_user.stances.count }.by -1
        expect(response.status).to eq 200
      end

      it 'cannot destroy verified stances' do
        sign_in user
        stance.update(participant: user)
        expect{post :destroy, params: { id: stance.id }}.to_not change { unverified_user.stances.count }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'create' do

    let(:another_user) { create :user, email: 'another_user@example.com', email_verified: false }
    let(:membership) { create :membership, user: build(:user, name: "unverified", email: 'user@example.com', email_verified: false), group: poll.guest_group }
    let(:user)       { create :user, name: "unverified", email: 'user@example.com', email_verified: false }
    let(:poll)       { create :poll }
    let(:poll_option) { create :poll_option, poll: poll }
    let(:visitor_stance_params) {{
      poll_id: poll.id,
      stance_choices_attributes: [{poll_option_id: poll_option.id}],
      visitor_attributes: { name: "Johnny Doe, not logged in", email: "user@example.com", legal_accepted: true}
    }}

    # test logged out cannot create a stance
    # non member cannot create a stance
    # unverified user gets verification email on stance create
    # if polls is anonymous you still get your own stance back

    it 'returns 403 for logged out users' do
      post :create, params: { stance: stance_params }
      expect(response.status).to eq 403
    end

    describe "non member votes" do
      it "denies access" do
        sign_in create :user
        post :create, params: {stance: stance_params}
        expect(response.status).to eq 403
      end
    end

    describe "unverified member votes" do
      it "creates stance and updates name and email" do
        poll.guest_group.add_member! user
        sign_in user
        expect { post :create, params: {stance: visitor_stance_params } }.to change {ActionMailer::Base.deliveries.count}.by 1
        expect(user.stances.count).to eq 1
        expect(response.status).to eq 200
        expect(user.reload.name).to eq visitor_stance_params[:visitor_attributes][:name]
        expect(user.reload.email).to eq visitor_stance_params[:visitor_attributes][:email]
        expect(user.reload.email_verified).to eq false
        expect(last_email_html_body).to include "Please verify your email address"
      end
    end

    describe "verified user votes" do
      it "creates stance and updates name and email" do
        user.update(email_verified: true)
        poll.guest_group.add_member! user
        sign_in user
        expect { post :create, params: {stance: stance_params } }.to_not change {ActionMailer::Base.deliveries.count}
        expect(user.stances.count).to eq 1
        expect(response.status).to eq 200
        expect(user.reload.email_verified).to eq true
      end
    end

    it 'includes the participant of the stance for anonymous polls' do
      poll.update(anonymous: true)
      user.update(email_verified: true)
      sign_in user
      poll.guest_group.add_member! user
      post :create, params: { stance: stance_params }
      json = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(json['stances'][0]['participant_id']).to eq user.id
      expect(json['users']).to be_present
    end

    describe 'poll.group.members_can_vote false' do
      let(:user) { create(:user) }

      before do
        group = create(:formal_group, members_can_vote: false)
        poll.update(group: group, discussion: create(:discussion, group: group))
        sign_in user
      end

      it 'admin of formal group can vote' do
        poll.group.add_admin! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end

      it 'admin of discussion guest group can vote' do
        poll.discussion.guest_group.add_admin! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end

      it 'admin of poll guest group can vote' do
        poll.guest_group.add_admin! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end

      it 'member of formal group cannot vote' do
        poll.group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 403
      end

      it 'member of discussion guest group cannot vote' do
        poll.discussion.guest_group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 403
      end

      it 'member of poll guest group can vote' do
        poll.guest_group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 403
      end
    end

    describe 'poll.group.members_can_vote true' do
      let(:user) { create(:user) }
      before do
        group = create(:formal_group, members_can_vote: true)
        poll.update(group: group, discussion: create(:discussion, group: group))
        sign_in user
      end

      it 'member of formal group cannot vote' do
        poll.group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end

      it 'member of discussion guest group cannot vote' do
        poll.discussion.guest_group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end

      it 'member of poll guest group can vote' do
        poll.guest_group.add_member! user
        post :create, params: { stance: stance_params }
        expect(response.status).to eq 200
      end
    end

    describe 'poll.anyone_can_participate = true' do
      before do
        poll.update(anyone_can_participate: true)
        user
      end

      it 'logged in' do
        # add to group and create stance
        user.update(email_verified: true)
        sign_in user
        expect { post :create, params: { stance: stance_params} }.to change { Stance.count }.by(1)
        expect(Stance.last.participant).to eq user
        expect(poll.members).to include user
      end

      describe 'not logged in' do
        it 'user enters verified users email' do
          user.update(email_verified: true)
          # create stance and unverified user, send claim_or_destroy (only single vote claim)
          expect { post :create, params: { stance: visitor_stance_params} }.to change { Stance.count }.by(1)
          stance = Stance.last
          expect(stance.participant.email_verified).to eq false
          expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]
          expect(poll.members).to include stance.participant
          expect(poll.members).to_not include User.verified.find_by(email: stance.participant.email)
          expect(last_email.to).to eq [stance.participant.email]
          expect(last_email_html_body).to include "confirm your vote"
        end

        it 'user enters unverified users email' do
          # create stance and unverified user -> send verify/login email
          user.update(email_verified: false)
          expect { post :create, params: { stance: visitor_stance_params} }.to change { Stance.count }.by(1)
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
          expect { post :create, params: { stance: visitor_stance_params} }.to change { Stance.count }.by(1)
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

  describe "create as logged out without token on public poll" do
    it 'creates a new stance' do
      expect { post :create, params: { stance: visitor_stance_params } }.to change { Stance.count }.by(1)

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

  describe "create as logged in member without token" do
    before { group.add_member! user }

    it 'creates a new stance' do
      sign_in user
      expect { post :create, params: { stance: stance_params } }.to change { Stance.count }.by(1)

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

    it 'overwrites existing stances' do
      sign_in user
      old_stance
      expect { post :create, params: { stance: stance_params } }.to change { Stance.count }.by(1)
      expect(response.status).to eq 200
      expect(old_stance.reload.latest).to eq false
    end

    it 'does not allow non members to create stances' do
      sign_in another_user
      expect { post :create, params: { stance: stance_params } }.to_not change { Stance.count }
      expect(response.status).to eq 403
    end

    it 'does not allow creating an invalid stance' do
      sign_in user
      stance_params[:poll_id] = proposal.id
      stance_params[:stance_choices_attributes] = []
      expect { post :create, params: { stance: stance_params } }.to_not change { Stance.count }
      expect(response.status).to eq 422
    end
  end
end
