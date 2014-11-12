require 'rails_helper'
describe API::MotionsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }
  let(:motion_params) {{
    name: 'hello',
    description: 'is it me you\'re looking for?',
    closing_at: '2013-05-05 02:00',
    discussion_id: discussion.id
  }}

  before do
    group.admins << user
    sign_in user
  end

   describe 'index' do
    let(:another_discussion)    { create :discussion }
    let(:another_motion)      { create :motion, discussion: another_discussion }

    before do
      motion; another_motion
    end

    context 'success' do
      it 'returns motion filtered by discussion' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[motions])
        motions = json['motions'].map { |v| v['id'] }
        expect(motions).to include motion.id
        expect(motions).to_not include another_motion.id
      end

      it 'does not show motion not visible to the current user' do
        cant_see_me = create :motion
        get :index, format: :json
        json = JSON.parse(response.body)
        motion = json['motions'].map { |v| v['id'] }
        expect(motion).to_not include cant_see_me.id
      end
    end
  end

  describe 'update' do
    context 'success' do
      it "updates a motion" do
        post :update, id: motion.id, motion: motion_params, format: :json
        expect(response).to be_success
        expect(motion.reload.name).to eq motion_params[:name]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        motion_params[:dontmindme] = 'wild wooly byte virus'
        expect { put :update, id: motion.id, motion: motion_params, format: :json }.to raise_error 
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { put :update, id: motion.id, motion: motion_params, format: :json }.to raise_error
      end

      it "responds with validation errors when they exist" do
        motion_params[:name] = ''
        put :update, id: motion.id, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['name']).to include 'can\'t be blank'
      end
    end
  end

  describe 'create' do
    context 'success' do
      it "creates a motion" do
        post :create, motion: motion_params, format: :json
        expect(response).to be_success
        expect(Motion.last).to be_present
      end

      it 'responds with json' do
        post :create, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users motions])
        expect(json['motions'][0].keys).to include *(%w[
          discussion_id
          name
          description
          outcome
          votes_count
          did_not_votes_count
          created_at
          updated_at
          closing_at
          closed_at
          last_vote_at
          vote_counts])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        motion_params[:dontmindme] = 'wild wooly byte virus'
        expect { post :create, motion: motion_params, format: :json }.to raise_error 
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :create, motion: motion_params, format: :json }.to raise_error
      end

      it "responds with validation errors when they exist" do
        motion_params[:name] = ''
        post :create, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['name']).to include 'can\'t be blank'
      end

    end
  end
end
