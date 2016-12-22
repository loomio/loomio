require 'rails_helper'

describe API::StancesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:poll) { create :poll, discussion: discussion }
  let(:poll_option) { PollTemplate.motion_template.poll_options.first }
  let(:old_stance) { create :stance, poll: poll, participant: user, poll_option: poll_option }
  let(:discussion) { create :discussion, group: group }
  let(:group) { create :group }
  let(:stance_params) {{
    poll_id: poll.id,
    poll_option_id: poll_option.id,
    statement: "here is my stance"
  }}
  before { group.add_member! user }

  describe 'index' do

  end

  describe 'create' do
    it 'creates a new stance' do
      sign_in user
      expect { post :create, stance: stance_params }.to change { Stance.count }.by(1)

      stance = Stance.last
      expect(stance.poll).to eq poll
      expect(stance.poll_option).to eq poll_option
      expect(stance.statement).to eq stance_params[:statement]
      expect(stance.latest).to eq true

      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['stances'].length).to eq 1
      expect(json['stances'][0]['id']).to eq stance.id
      expect(json['polls'].length).to eq 1
      expect(json['polls'][0]['key']).to eq poll.key
      expect(json['poll_options'].length).to eq 1
      expect(json['poll_options'][0]['name']).to eq poll_option.name
    end

    it 'overwrites existing stances' do
      sign_in user
      old_stance
      expect { post :create, stance: stance_params }.to change { Stance.count }.by(1)
      expect(response.status).to eq 200
      expect(old_stance.reload.latest).to eq false
    end

    it 'does not allow visitors to create stances' do
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
      stance_params[:poll_option_id] = nil
      expect { post :create, stance: stance_params }.to_not change { Stance.count }
      expect(response.status).to eq 422
    end
  end
end
