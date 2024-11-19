require 'rails_helper'

describe API::V1::DocumentsController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  describe 'for_group' do
    let!(:group_document) { create :document, model: group }
    let!(:discussion_document) { create :document, model: discussion }

    describe 'open' do
      before do
        group.update(group_privacy: 'open')
        discussion.update(private: false)
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include discussion_document.id
      end

      it 'displays all documents for visitors' do
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include discussion_document.id
      end
    end

    describe 'secret' do
      before do
        group.update(group_privacy: 'secret')
        discussion.update(private: true)
      end

      it 'unauthorized for non-members' do
        sign_in user
        get :for_group, params: { group_id: group.id }
        expect(response.status).to eq 403
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include discussion_document.id
      end
    end
  end

  describe 'for_discussion' do
    let!(:discussion) { create :discussion, group: group }
    let!(:poll) { create :poll, discussion: discussion }
    let!(:comment) { create :comment, discussion: discussion }
    let!(:discussion_document) { create :document, model: discussion }
    let!(:poll_document) { create :document, model: poll }
    let!(:comment_document) { create :document, model: comment }

    let!(:another_discussion) { create :discussion }
    let!(:another_poll) { create :poll, discussion: another_discussion }
    let!(:another_comment) { create :comment, discussion: another_discussion }
    let!(:another_discussion_document) { create :document, model: another_discussion }
    let!(:another_poll_document) { create :document, model: another_poll }
    let!(:another_comment_document) { create :document, model: another_comment }

    before { group.add_member! user }

    it 'returns documents for the discussion and its comments' do
      sign_in user
      get :for_discussion, params: { discussion_id: discussion.id }
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      document_ids = json['documents'].map { |d| d['id'] }
      expect(document_ids).to include discussion_document.id
      expect(document_ids).to include poll_document.id
      expect(document_ids).to include comment_document.id
      expect(document_ids).to_not include another_discussion_document.id
      expect(document_ids).to_not include another_poll_document.id
      expect(document_ids).to_not include another_comment_document.id
    end

    it 'does not allow non-members to see the documents' do
      sign_in another_user
      get :for_discussion, params: { discussion_id: discussion.id }
      expect(response.status).to eq 403
    end
  end
end
