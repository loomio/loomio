require 'rails_helper'

describe API::OutcomesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:outcome) { create :outcome, poll: poll, author: user }
  let(:poll) { create :poll, discussion: discussion, closed_at: 1.day.ago, author: user }
  let(:another_poll) { create :poll, discussion: discussion, closed_at: 1.day.ago, author: user }
  let(:discussion) { create :discussion, group: group }
  let(:group) { create :group }
  let(:outcome_params) {{ poll_id: poll.id, statement: "We should do this" }}

  before { group.add_member! user }

  describe 'create' do
    it 'creates a new outcome' do
      sign_in user
      expect { post :create, outcome: outcome_params }.to change { Outcome.count }.by(1)

      outcome = Outcome.last
      expect(outcome.statement).to eq outcome_params[:statement]
      expect(outcome.poll).to eq poll
    end

    it 'does not allow creating an invalid outcome' do
      sign_in user
      outcome_params[:statement] = ""
      expect { post :create, outcome: outcome_params }.to_not change { Outcome.count }
      expect(response.status).to eq 422
    end

    it 'does not allow visitors to create outcomes' do
      expect { post :create, outcome: outcome_params }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end

    it 'does not allow non members to create outcomes' do
      sign_in another_user
      expect { post :create, outcome: outcome_params }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end

    it 'does not allow outcomes on open polls' do
      sign_in user
      poll.update(closed_at: nil)
      expect { post :create, outcome: outcome_params }.to_not change { Outcome.count }
      expect(response.status).to eq 403
    end
  end

  describe 'update' do
    it 'creates a new outcome in place of an existing one' do
      sign_in user
      outcome
      expect { post :update, id: outcome.id, outcome: outcome_params }.to change { Outcome.count }.by(1)
      expect(response.status).to eq 200

      new_outcome = Outcome.last

      expect(new_outcome.statement).to eq outcome_params[:statement]
      expect(new_outcome.latest).to eq true
      expect(outcome.reload.latest).to eq false
    end

    it 'does not allow updating to an invalid outcome' do
      sign_in user
      outcome_params[:statement] = ""
      post :update, id: outcome.id, outcome: outcome_params
      expect(response.status).to eq 422
    end

    it 'does not allow outcomes to switch polls' do
      sign_in user
      post :update, id: outcome.id, outcome: { poll_id: another_poll.id }
      expect(response.status).to eq 422
      expect(outcome.reload.poll).to eq poll
    end

    it 'does not allow visitors to update outcomes' do
      post :update, id: outcome.id, outcome: outcome_params
      expect(response.status).to eq 403
    end

    it 'does not allow non members to update outcomes' do
      sign_in another_user
      post :update, id: outcome.id, outcome: outcome_params
      expect(response.status).to eq 403
    end

    it 'does not allow outcomes to be updated on open polls' do
      sign_in user
      poll.update(closed_at: nil)
      post :update, id: outcome.id, outcome: outcome_params
      expect(response.status).to eq 403
    end
  end
end
