require 'rails_helper'
describe API::DraftsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }

  let(:user_draft) { create :draft, user: user, draftable: user }
  let(:group_draft) { create :draft, user: user, draftable: group }
  let(:discussion_draft) { create :draft, user: user, draftable: discussion }

  let(:user_draft_params) {{
    payload: {
      group: {
        name: 'Draft group name',
        description: 'Draft group description'
      }
    }
  }}

  let(:group_draft_params) {{
    payload: {
      discussion: {
        title: 'Draft discussion title',
        description: 'Draft discussion description'
      }
    }
  }}
  let(:discussion_draft_params) {{
    payload: {
      comment: {
        body: 'Draft comment body'
      }
    }
  }}

  context 'signed out' do
    describe 'show' do
      it 'returns unauthorized for a group' do
        group_draft
        get :show, params: { draftable_type: 'Group', draftable_id: group.id }, format: :json
        expect(response.status).to eq 403
      end

      it 'returns unauthorized for a discussion' do
        discussion_draft
        get :show, params: { draftable_type: 'Group', draftable_id: discussion.id }, format: :json
        expect(response.status).to eq 403
      end

    end
  end

  context 'signed in' do
    before do
      sign_in user
      group.add_member! user
    end

    describe 'create' do
      it 'creates a new user draft' do
        post :update, params: { draft: user_draft_params, draftable_type: 'user', draftable_id: user.id }
        expect(response.status).to eq 200

        draft = Draft.last
        expect(draft.draftable).to eq user
        expect(draft.user).to eq user
        expect(draft.payload['group']['name']).to eq user_draft_params[:payload][:group][:name]
        expect(draft.payload['group']['description']).to eq user_draft_params[:payload][:group][:description]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['group']['name']).to eq user_draft_params[:payload][:group][:name]
        expect(json['drafts'][0]['payload']['group']['description']).to eq user_draft_params[:payload][:group][:description]
      end

      it 'creates a new group draft' do
        post :update, params: { draft: group_draft_params, draftable_type: 'group', draftable_id: group.id }
        expect(response.status).to eq 200

        draft = Draft.last
        expect(draft.draftable).to eq group
        expect(draft.user).to eq user
        expect(draft.payload['discussion']['title']).to eq group_draft_params[:payload][:discussion][:title]
        expect(draft.payload['discussion']['description']).to eq group_draft_params[:payload][:discussion][:description]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['discussion']['title']).to eq group_draft_params[:payload][:discussion][:title]
        expect(json['drafts'][0]['payload']['discussion']['description']).to eq group_draft_params[:payload][:discussion][:description]
      end

      it 'creates a new discussion draft' do
        post :update, params: { draft: discussion_draft_params, draftable_type: 'discussion', draftable_id: discussion.id }
        expect(response.status).to eq 200

        draft = Draft.last
        expect(draft.draftable).to eq discussion
        expect(draft.user).to eq user
        expect(draft.payload['comment']['body']).to eq discussion_draft_params[:payload][:comment][:body]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['comment']['body']).to eq discussion_draft_params[:payload][:comment][:body]
      end


      it 'overwrites a user draft' do
        user_draft
        post :update, params: { draft: user_draft_params, draftable_type: 'user', draftable_id: user.id }
        expect(response.status).to eq 200

        user_draft.reload
        expect(user_draft.draftable).to eq user
        expect(user_draft.user).to eq user
        expect(user_draft.payload['group']['name']).to eq user_draft_params[:payload][:group][:name]
        expect(user_draft.payload['group']['description']).to eq user_draft_params[:payload][:group][:description]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['group']['name']).to eq user_draft_params[:payload][:group][:name]
        expect(json['drafts'][0]['payload']['group']['description']).to eq user_draft_params[:payload][:group][:description]
      end

      it 'overwrites a group draft' do
        group_draft
        post :update, params: { draft: group_draft_params, draftable_type: 'group', draftable_id: group.id }
        expect(response.status).to eq 200

        group_draft.reload
        expect(group_draft.draftable).to eq group
        expect(group_draft.user).to eq user
        expect(group_draft.payload['discussion']['title']).to eq group_draft_params[:payload][:discussion][:title]
        expect(group_draft.payload['discussion']['description']).to eq group_draft_params[:payload][:discussion][:description]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['discussion']['title']).to eq group_draft_params[:payload][:discussion][:title]
        expect(json['drafts'][0]['payload']['discussion']['description']).to eq group_draft_params[:payload][:discussion][:description]
      end

      it 'overwrites a discussion draft' do
        discussion_draft
        post :update, params: { draft: discussion_draft_params, draftable_type: 'discussion', draftable_id: discussion.id }
        expect(response.status).to eq 200

        discussion_draft.reload
        expect(discussion_draft.draftable).to eq discussion
        expect(discussion_draft.user).to eq user
        expect(discussion_draft.payload['comment']['body']).to eq discussion_draft_params[:payload][:comment][:body]

        json = JSON.parse(response.body)
        expect(json['drafts'][0]['payload']['comment']['body']).to eq discussion_draft_params[:payload][:comment][:body]
      end

      it 'cannot access a group the user does not have access to' do
        expect { post :update, params: { draft: group_draft_params, draftable_type: 'group', draftable_id: another_group.id } }.not_to change { Draft.count }
        expect(response.status).to eq 403
      end
    end
  end
end
