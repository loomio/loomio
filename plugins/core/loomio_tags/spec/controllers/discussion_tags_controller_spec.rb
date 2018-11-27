require 'rails_helper'

describe ::API::DiscussionTagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :formal_group }
  let(:another_group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:another_discussion) { create :discussion, group: group }
  let(:hidden_discussion) { create :discussion }

  let(:tag) { create :tag, name: "My tag", group: group }
  let(:another_tag) { create :tag, name: "Hidden tag", group: another_group }
  let!(:discussion_tag) { create :discussion_tag, tag: tag, discussion: discussion }
  let!(:another_discussion_tag) { create :discussion_tag, tag: tag, discussion: another_discussion }
  let!(:hidden_discussion_tag) { create :discussion_tag, tag: another_tag, discussion: hidden_discussion }

  let(:discussion_tag_params) {{
    tag_id: tag.id,
    discussion_id: discussion.id
  }}

  before { sign_in user }

  describe 'create' do
    it 'can create a tag' do
      group.add_member! user
      expect { post :create, params: {discussion_tag: discussion_tag_params} }.to change { DiscussionTag.count }.by(1)

      json = JSON.parse(response.body)
      expect(json['discussion_tags'][0]['tag_id']).to eq tag.id
      expect(json['discussion_tags'][0]['discussion_id']).to eq discussion.id
    end

    it 'cannot create a tag in a discussion the user does not have access to' do
      expect { post :create, params: {discussion_tag: discussion_tag_params} }.to_not change { DiscussionTag.count }
      expect(response.status).to eq 403
    end
  end

  describe 'destroy' do
    it 'can destroy a tag' do
      group.add_member! user
      expect { delete :destroy, params: { id: discussion_tag.id } }.to change { DiscussionTag.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'does not allow destroying tags the user does not have access to' do
      expect { delete :destroy, params: { id: discussion_tag.id } }.to_not change { DiscussionTag.count }
      expect(response.status).to eq 403
    end
  end

end
