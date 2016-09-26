require 'rails_helper'
describe API::MotionsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group, is_visible_to_public: true  }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group, private: false }
  let(:private_discussion) { create :discussion, group: group, private: true }
  let(:private_motion) { create :motion, discussion: private_discussion }
  let(:motion) { create :motion, discussion: discussion }
  let(:another_motion) { create :motion }
  let(:motion_params) {{
    name: 'hello',
    description: 'is it me you\'re looking for?',
    discussion_id: discussion.id
  }}
  let(:my_vote) { create :vote, motion: motion, author: user }
  let(:attachment) { create :attachment }

  before do
    group.admins << user
    sign_in user
  end

  describe 'show' do

    it 'returns motions the user has access to' do
      get :show, id: motion.id, format: :json
      json = JSON.parse(response.body)
      motion_ids = json['proposals'].map { |m| m['id'] }
      expect(motion_ids).to eq [motion.id]
    end

    it 'returns unauthorized for motions the user does not have access to' do
      get :show, id: another_motion.id, format: :json
      expect(response.status).to eq 403
    end

    context 'logged out' do
      before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }

      it 'returns a motion if it is public' do
        get :show, id: motion.id, format: :json
        json = JSON.parse(response.body)
        motion_ids = json['proposals'].map { |m| m['id'] }
        expect(motion_ids).to eq [motion.id]
      end

      it 'returns unauthorized if it is not public' do
        get :show, id: private_motion.id, format: :json
        expect(response.status).to eq 403
      end
    end
  end

  describe 'index' do
    let(:another_discussion) { create :discussion }
    let(:another_motion) { create :motion, discussion: another_discussion }

    before do
      motion; another_motion
    end

    context 'success' do
      it 'returns motion filtered by discussion' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[proposals])
        motion_ids = json['proposals'].map { |v| v['id'] }
        expect(motion_ids).to include motion.id
        expect(motion_ids).to_not include another_motion.id
      end

      context 'logged out' do
        before { @controller.stub(:current_user).and_return(LoggedOutUser.new) }

        it 'returns motions filtered for public discussion' do
          get :index, discussion_id: discussion.id, format: :json
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[proposals])
          motion_ids = json['proposals'].map { |v| v['id'] }
          expect(motion_ids).to include motion.id
          expect(motion_ids).to_not include another_motion.id
        end

        it 'returns unauthorized for private discussion' do
          get :index, discussion_id: private_discussion.id, format: :json
        end
      end
    end
  end

  describe 'closed' do

    let(:public_group)       { create :group, is_visible_to_public: true }
    let(:public_discussion)  { create :discussion, group: public_group, private: false }
    let(:public_motion)      { create :motion, discussion: public_discussion }

    it 'returns closed motions for a group' do
      my_vote
      MotionService.close(motion)
      post :closed, group_key: group.key, format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to include *(%w[votes proposals discussions groups])
      group_ids = json['groups'].map { |g| g['id'] }
      discussion_ids = json['discussions'].map { |d| d['id'] }
      motion_ids = json['proposals'].map { |v| v['id'] }
      vote_ids = json['votes'].map { |v| v['id'] }

      expect(group_ids).to include group.id
      expect(discussion_ids).to include discussion.id
      expect(motion_ids).to include motion.id
      expect(vote_ids).to include my_vote.id

      expect(group_ids).to_not include another_group.id
      expect(discussion_ids).to_not include private_discussion.id
      expect(motion_ids).to_not include another_motion.id
    end

    it 'returns public motions' do
      MotionService.close(public_motion)
      get :closed, group_key: public_group.key, format: :json
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      motion_ids = json['proposals'].map { |p| p['id'] }
      expect(motion_ids).to include public_motion.id
    end

    it 'does not return votes if I havent voted' do
      MotionService.close(motion)
      post :closed, group_key: group.key, format: :json
      json = JSON.parse(response.body)
      expect(json.keys).to_not include 'votes'
    end

    it 'returns unauthorized for groups youre not a member of' do
      post :closed, group_key: another_group.key
    end
  end

  describe 'close' do
    context 'success' do
      it "closes a motion" do
        post :close, id: motion.id, format: :json
        expect(response).to be_success
        expect(motion.reload.closed_at).not_to eq nil
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :close, id: motion.id
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
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

      it 'adds attachments' do
        motion_params[:attachment_ids] = attachment.id
        post :update, id: motion.id, motion: motion_params, format: :json
        expect(motion.reload.attachments).to include attachment
        json = JSON.parse(response.body)
        attachment_ids = json['attachments'].map { |a| a['id'] }
        expect(attachment_ids).to include attachment.id
      end

      it 'removes attachments' do
        attachment.update(attachable: discussion)
        motion_params[:attachment_ids] = []
        post :update, id: motion.id, motion: motion_params, format: :json
        expect(motion.reload.attachments).to be_empty
        json = JSON.parse(response.body)
        attachment_ids = json['attachments'].map { |a| a['id'] }
        expect(attachment_ids).to_not include attachment.id
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        motion_params[:dontmindme] = 'wild wooly byte virus'
        put :update, id: motion.id, motion: motion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        put :update, id: motion.id, motion: motion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        motion_params[:name] = ''
        put :update, id: motion.id, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['name']).to include 'can\'t be blank'
      end
    end
  end

  describe 'create outcome' do
    context 'success' do
      it "creates a motion outcome" do
        motion_params = {outcome: 'Come out'}
        post :create_outcome, id: motion.id, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(json['proposals'].first['outcome']).to eq motion_params[:outcome]
      end
    end
  end

  describe 'update outcome' do
    context 'success' do
      it "updates a motion outcome" do
        post :update_outcome, id: motion.id, motion: motion_params, format: :json
        json = JSON.parse(response.body)
        motion_ids = json['proposals'].map { |v| v['id'] }
        expect(motion_ids).to include motion.id
        expect(motion.reload.outcome).to eq motion_params[:outcome]
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
        expect(json.keys).to include *(%w[users proposals])
        expect(json['proposals'][0].keys).to include *(%w[
          discussion_id
          name
          description
          outcome
          activity_count
          members_count
          voters_count
          created_at
          updated_at
          closing_at
          closed_at
          last_vote_at
          vote_counts])
      end

      it 'responds with a discussion with a reader' do
        post :create, motion: motion_params
        json = JSON.parse(response.body)
        expect(json['discussions'][0]['discussion_reader_id']).to be_present
      end

      describe 'mentioning' do
        it 'mentions appropriate users' do
          group.add_member! another_user
          motion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, motion: motion_params, format: :json }.to change { Event.where(kind: :user_mentioned).count }.by(1)
        end

        it 'does not mention users not in the group' do
          motion_params[:description] = "Hello, @#{another_user.username}!"
          expect { post :create, motion: motion_params, format: :json }.to_not change { Event.where(kind: :user_mentioned).count }
        end
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        motion_params[:dontmindme] = 'wild wooly byte virus'
        post :create, motion: motion_params
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        post :create, motion: motion_params
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end

      it "responds with validation errors when they exist" do
        motion_params[:name] = ''
        post :create, motion: motion_params
        json = JSON.parse(response.body)
        expect(response.status).to eq 422
        expect(json['errors']['name']).to include 'can\'t be blank'
      end

    end
  end
end
