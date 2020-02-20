require 'rails_helper'

describe API::DocumentsController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:public_discussion) { create :discussion, group: group, private: false }
  let(:private_discussion) { create :discussion, group: group, private: true }

  describe 'for_group' do
    let!(:group_document) { create :document, model: group }
    let!(:public_discussion_document) { create :document, model: public_discussion }
    let!(:private_discussion_document) { create :document, model: private_discussion }

    describe 'open' do
      before { group.update(group_privacy: 'open') }

      it 'displays all documents for non-members' do
        sign_in user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays all documents for visitors' do
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end
    end

    describe 'closed' do
      before { group.update(group_privacy: 'closed') }

      it 'displays public documents for non-members' do
        sign_in user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to_not include private_discussion_document.id
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays public documents for visitors' do
        get :for_group, params: { group_id: group.id }
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to_not include private_discussion_document.id
      end
    end

    describe 'secret' do
      before { group.update(group_privacy: 'secret') }

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
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays public documents in the closed group for non-members' do
        sign_in user
        get :for_group, params: { group_id: group.id }
        expect(response.status).to eq 403
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
