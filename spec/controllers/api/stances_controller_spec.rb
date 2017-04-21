require 'rails_helper'

describe API::StancesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:poll) { create :poll, discussion: discussion }
  let(:proposal) { create :poll_proposal, discussion: discussion }
  let(:poll_option) { create :poll_option, poll: poll }
  let(:old_stance) { create :stance, poll: poll, participant: user, poll_options: [poll_option] }
  let(:discussion) { create :discussion, group: group }
  let(:group) { create :group }
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
    visitor_attributes: { name: "John Doe", email: "john@doe.ninja" }
  }}

  before { group.add_member! user }

  describe 'index' do
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

    it 'can create a stance with a visitor' do
      expect { post :create, stance: visitor_stance_params }.to change { Stance.count }.by(1)

      stance = Stance.last
      expect(stance.participant.name).to  eq visitor_stance_params[:visitor_attributes][:name]
      expect(stance.participant.email).to eq visitor_stance_params[:visitor_attributes][:email]

      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      names  = json['visitors'].map { |u| u['name'] }
      emails = json['visitors'].map { |u| u['email'] }

      expect(names).to  include visitor_stance_params[:visitor_attributes][:name]
      expect(emails).to include visitor_stance_params[:visitor_attributes][:email]
    end

    it 'does not create a stance with an incomplete visitor' do
      visitor_stance_params[:visitor_attributes] = {}
      expect { post :create, stance: visitor_stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 422

      json = JSON.parse(response.body)
      expect(json['errors']['participant_name']).to be_present
    end

    it 'does not allow unauthorized visitors to create stances' do
      visitor_stance_params[:poll_id] = poll.id
      expect { post :create, stance: visitor_stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 403
    end

    it 'overwrites existing stances' do
      sign_in user
      old_stance
      expect { post :create, stance: stance_params }.to change { Stance.count }.by(1)
      expect(response.status).to eq 200
      expect(old_stance.reload.latest).to eq false
    end

    it 'does not allow unauthorized visitors to create stances' do
      expect { post :create, stance: stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 403
    end

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
