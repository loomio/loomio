require 'rails_helper'

describe API::TranslationsController do

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:comment) { create(:comment, discussion: discussion) }
  let(:discussion_translation) { create(:translation, translatable: discussion, language: :fr, fields: { title: "title", description: "description"}) }
  let(:comment_translation) { create(:translation, translatable: comment, language: :fr, fields: { body: "body" }) }

  before do
    sign_in user
  end

  describe 'show' do
    it 'returns a translation based on lang parameter' do
      get :show, params: { lang: :es }
      json = JSON.parse(response.body)
      expect(json.dig('common', 'action', 'save')).to eq 'Guardar'
    end

    it 'returns english by default' do
      get :show
      json = JSON.parse(response.body)
      expect(json.dig('common', 'action', 'save')).to eq 'Save'
    end

    it 'returns a modified translation based on vue parameter' do
      get :show, params: { vue: true }
      json = JSON.parse(response.body)
      expect(json.dig('common', 'closing_in')).to eq 'Closing {time}'
    end
  end

  describe 'inline' do
    context 'success' do

      it 'responds with an inline translation for a discussion' do
        discussion_translation
        get :inline, params: { model: 'discussion', id: discussion.id, to: :fr }
        json = JSON.parse(response.body)
        translatable_ids = json['translations'].map { |t| t['translatable_id'] }
        translatable_types = json['translations'].map { |t| t['translatable_type'] }
        expect(translatable_ids).to include discussion.id
        expect(translatable_types).to include 'Discussion'
      end

      it 'responds with an inline translation for a comment' do
        comment_translation
        get :inline, params: { model: 'comment', id: comment.id, to: :fr }
        json = JSON.parse(response.body)
        translatable_ids = json['translations'].map { |t| t['translatable_id'] }
        translatable_types = json['translations'].map { |t| t['translatable_type'] }
        expect(translatable_ids).to include comment.id
        expect(translatable_types).to include 'Comment'
      end

      it 'does not translate an unknown language' do
        get :inline, params: { model: 'comment', id: comment.id, to: :wark }
        expect(response.status).to eq 422
        json = JSON.parse(response.body)
        expect(json['errors'].keys).to include 'language'
      end

    end
  end

end
