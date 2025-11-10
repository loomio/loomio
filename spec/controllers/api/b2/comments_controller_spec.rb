require 'rails_helper'

describe Api::B2::CommentsController do
  let(:group) { create :group }
  let(:user) { group.admins.first }
  let(:another_user) { create :user }
  let(:discussion) { create :discussion, group: group }

  before do
    group.add_member! user
    DiscussionService.create(discussion: discussion, actor: user)
  end

  describe 'create' do
    it 'happy case' do
      user.update(api_key: 'abc123')
      post :create, params: {
        body: 'This is a test comment',
        body_format: 'md',
        discussion_id: discussion.id,
        api_key: user.api_key
      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      comment = json['comments'][0]
      expect(comment['id']).to be_present
      expect(comment['discussion_id']).to eq discussion.id
      expect(comment['body']).to eq 'This is a test comment'
    end

    it 'missing discussion_id' do
      user.update(api_key: 'abc123')
      post :create, params: {
        body: 'Test comment',
        api_key: user.api_key
      }
      expect(response.status).to eq 403
    end

    it 'blank body' do
      user.update(api_key: 'abc123')
      post :create, params: {
        body: '',
        discussion_id: discussion.id,
        api_key: user.api_key
      }
      expect(response.status).to eq 422
    end

    it 'missing permission' do
      another_user.update(api_key: 'def456')
      post :create, params: {
        body: 'Test comment',
        discussion_id: discussion.id,
        api_key: another_user.api_key
      }
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      post :create, params: {
        body: 'Test comment',
        discussion_id: discussion.id,
        api_key: 'wrongkey123'
      }
      expect(response.status).to eq 403
    end

    it 'blank key' do
      post :create, params: {
        body: 'Test comment',
        discussion_id: discussion.id
      }
      expect(response.status).to eq 403
    end
  end
end
