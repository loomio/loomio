require 'rails_helper'

describe ::API::DiscussionsController, type: :controller do

  let(:user) { create :user }
  let(:public_group) { create :formal_group, is_visible_to_public: true }
  let(:group) { create :formal_group, is_visible_to_public: false }
  let(:tag) { create :tag, group: group }
  let(:discussion) { create :discussion, group: group }
  let!(:discussion_tag) { create :discussion_tag, discussion: discussion, tag: tag }
  let!(:another_discussion) { create :discussion, group: group }
  before { sign_in user }

  describe 'show' do
    it 'returns discussion tags with the discussion' do
      group.add_member! user
      get :show, params: { id: discussion.key }
      json = JSON.parse(response.body)

      discussion_tag_ids = json['discussion_tags'].map { |t| t['id'] }
      expect(discussion_tag_ids).to include discussion_tag.id

      tag_ids = json['tags'].map { |t| t['id'] }
      expect(tag_ids).to include tag.id
    end
  end

  describe 'index' do

    it 'returns tags with discussions' do
      group.add_member! user
      get :index, params: { group_id: group.key }
      json = JSON.parse(response.body)

      discussion_tag_ids = json['discussion_tags'].map { |t| t['id'] }
      expect(discussion_tag_ids).to include discussion_tag.id

      tag_ids = json['tags'].map { |t| t['id'] }
      expect(tag_ids).to include tag.id
    end
  end

  describe 'tags' do

    it 'returns threads associated with a tag' do
      group.add_member! user
      get :tags, params: { tag_id: tag.id }
      json = JSON.parse(response.body)

      discussion_ids = json['discussions'].map { |t| t['id'] }

      expect(discussion_ids).to include discussion.id
      expect(discussion_ids).to_not include another_discussion.id
    end

    it 'does not return a tag for a group the user is not a member of' do
      get :tags, params: { tag_id: tag.id }
      expect(response.status).to eq 403
    end
  end

end
