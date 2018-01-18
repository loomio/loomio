require 'rails_helper'

describe API::DocumentsController do
  let(:user) { create :user }
  let(:group) { create :formal_group }
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
        get :for_group, group_id: group.id
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, group_id: group.id
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays all documents for visitors' do
        get :for_group, group_id: group.id
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
        get :for_group, group_id: group.id
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to_not include private_discussion_document.id
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, group_id: group.id
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays public documents for visitors' do
        get :for_group, group_id: group.id
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
        get :for_group, group_id: group.id
        expect(response.status).to eq 403
      end

      it 'displays all documents for members' do
        sign_in user
        group.add_member! user
        get :for_group, group_id: group.id
        json = JSON.parse response.body
        document_ids = json['documents'].map { |d| d['id'] }

        expect(document_ids).to include group_document.id
        expect(document_ids).to include public_discussion_document.id
        expect(document_ids).to include private_discussion_document.id
      end

      it 'displays public documents in the closed group for non-members' do
        sign_in user
        get :for_group, group_id: group.id
        expect(response.status).to eq 403
      end
    end
  end
end
