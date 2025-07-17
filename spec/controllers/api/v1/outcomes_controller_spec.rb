require 'rails_helper'

describe Api::V1::OutcomesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:outcome) { create :outcome, poll: poll, author: user }
  let(:poll) { create :poll, discussion: discussion, group: group, closed_at: 1.day.ago, author: user }
  let(:meeting_poll) { create :poll_meeting, discussion: discussion, closed_at: 1.day.ago, author: user }
  let(:another_poll) { create :poll, discussion: discussion, closed_at: 1.day.ago, author: user }
  let(:discussion) { create :discussion, group: group }
  let(:group) { create :group }
  let(:outcome_params) {{ poll_id: poll.id, statement: "We should do this" }}
  let(:meeting_params) { outcome_params.merge(
    poll_id: meeting_poll.id,
    poll_option_id: meeting_poll.poll_option_ids.first,
    event_description: "Eat those krabs",
    event_location: "The Krusty Krab"
    ) }

  before { group.add_member! user }

  describe 'create' do
    it 'creates a new outcome' do
      sign_in user
      expect { post :create, params: { outcome: outcome_params } }.to change { Outcome.count }.by(1)
      expect(response.status).to eq 200

      outcome = Outcome.last
      expect(outcome.statement).to eq outcome_params[:statement]
      expect(outcome.poll).to eq poll
    end

    it 'notifies group' do
      sign_in user
      group.add_member! another_user
      params = {
        poll_id: poll.id,
        statement: "we did it",
        recipient_audience: 'group',
      }
      expect { post :create, params: { outcome: params } }.to change { Outcome.count }.by(1)
      expect(response.status).to eq 200
      outcome = Outcome.find(JSON.parse(response.body)['outcomes'][0]['id'])
      expect(outcome.created_event.notifications.count).to eq 3
    end

    it 'does not allow creating an invalid outcome' do
      sign_in user
      outcome_params[:statement] = ""
      expect { post :create, params: { outcome: outcome_params } }.to_not change { Outcome.count }
      expect(response.status).to eq 422
    end

    it 'can associate a poll option with the outcome' do
      sign_in user
      outcome_params[:poll_option_id] = poll.poll_options.first.id
      expect { post :create, params: { outcome: outcome_params } }.to change { poll.outcomes.count }.by(1)
      expect(Outcome.last.poll_option).to eq poll.poll_options.first
    end

    it 'validates the poll option id' do
      sign_in user
      outcome_params[:poll_option_id] = create(:poll_proposal).poll_options.first.id
      expect { post :create, params: { outcome: outcome_params } }.to_not change { poll.outcomes.count }
      expect(response.status).to eq 422
    end

    it 'does not allow visitors to create outcomes' do
      expect { post :create, params: { outcome: outcome_params } }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end

    it 'does not allow non members to create outcomes' do
      sign_in another_user
      expect { post :create, params: { outcome: outcome_params } }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end

    it 'does not allow outcomes on open polls' do
      sign_in user
      poll.update(closed_at: nil)
      expect { post :create, params: { outcome: outcome_params } }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end

    it 'can store a calendar invite for date polls' do
      sign_in user
      expect { post :create, params: { outcome: meeting_params } }.to change { Outcome.count }.by(1)

      outcome = Outcome.last
      expect(outcome.event_description).to eq meeting_params[:event_description]
      expect(outcome.event_location).to eq meeting_params[:event_location]
      expect(outcome.calendar_invite).to be_present
      expect(outcome.calendar_invite).to match /#{meeting_params[:event_description]}/
      expect(outcome.calendar_invite).to match /#{meeting_params[:event_location]}/
    end
  end

  describe 'update' do
    it 'updates an outcome' do
      sign_in user
      outcome
      outcome_params[:statement] = "updated"
      expect { post :update, params: { id: outcome.id, outcome: outcome_params } }.to change { Outcome.count }.by(0)
      expect(response.status).to eq 200

      outcome.reload
      expect(outcome.statement).to eq "updated"
      expect(outcome.latest).to eq true
    end

    it 'does not allow updating to an invalid outcome' do
      sign_in user
      outcome_params[:statement] = ""
      post :update, params: { id: outcome.id, outcome: outcome_params }
      expect(response.status).to eq 422
    end

    # it 'does not allow outcomes to switch polls' do
    #   sign_in user
    #   post :update, params: { id: outcome.id, outcome: { poll_id: another_poll.id } }
    #   expect(response.status).to eq 422
    #   expect(outcome.reload.poll).to eq poll
    # end

    it 'does not allow visitors to update outcomes' do
      post :update, params: { id: outcome.id, outcome: outcome_params }
      expect(response.status).to eq 403
    end

    it 'does not allow non members to update outcomes' do
      sign_in another_user
      post :update, params: { id: outcome.id, outcome: outcome_params }
      expect(response.status).to eq 403
    end

    it 'does not allow outcomes to be updated on open polls' do
      sign_in user
      poll.update(closed_at: nil)
      post :update, params: { id: outcome.id, outcome: outcome_params }
      expect(response.status).to eq 403
    end
  end
end
