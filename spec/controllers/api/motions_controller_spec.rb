require 'rails_helper'
describe API::MotionsController do
  render_views

  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  before do
    group.admins << user
    sign_in user
  end

  describe 'create' do
    context 'success' do
      let(:motion_params) { {name: 'hello',
                             description: 'is it me you\'re looking for?',
                             closing_at: '2013-05-05 02:00',
                             discussion_id: discussion.id} }

      it "creates a proposal" do
        post :create, motion: motion_params, format: :json
        response.should be_success
      end

      it 'returns the event json' do
        post :create, motion: motion_params, format: :json
        event = JSON.parse(response.body)['event']
        proposals = JSON.parse(response.body)['proposals']
        event.keys.should include *(%w[id sequence_id kind proposal_id])
        proposals[0].keys.should include *(%w[name created_at description discussion_id closing_at])
      end
    end

    context 'error' do
      let(:motion_params) { {discussion_id: discussion.id} }

      it "gives 400 status" do
        post :create, motion: motion_params, format: :json
        response.status.should == 400
      end

      it 'calls render_event_or_model_error' do
        post :create, motion: motion_params, format: :json
        errors = JSON.parse(response.body)['error']['messages']
        errors.should == assigns[:motion].errors.full_messages
      end
    end
  end

  describe 'vote' do
    context 'success' do
      it 'creates a vote'
      it 'returns the event json'
    end

    context 'error' do

    end

  end
end

