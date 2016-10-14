require 'rails_helper'

describe API::TranslationsController do

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:comment) { create(:comment, discussion: discussion) }
  let(:discussion_translation) { create(:translation, translatable: discussion, language: :fr, fields: { title: "title", description: "description"}) }
  let(:motion_translation) { create(:translation, translatable: motion, language: :fr, fields: { name: "name", description: "description" }) }
  let(:comment_translation) { create(:translation, translatable: comment, language: :fr, fields: { body: "body" }) }

  before do
    sign_in user
    TranslationService.stub(:available?).and_return(true)
  end

  describe 'inline' do
    context 'success' do

      it 'responds with an inline translation for a discussion' do
        discussion_translation
        get :inline, model: 'discussion', id: discussion.id, to: :fr
        json = JSON.parse(response.body)
        translatable_ids = json['translations'].map { |t| t['translatable_id'] }
        translatable_types = json['translations'].map { |t| t['translatable_type'] }
        expect(translatable_ids).to include discussion.id
        expect(translatable_types).to include 'Discussion'
      end

      it 'responds with an inline translation for a motion' do
        motion_translation
        get :inline, model: 'motion', id: motion.id, to: :fr
        json = JSON.parse(response.body)
        translatable_ids = json['translations'].map { |t| t['translatable_id'] }
        translatable_types = json['translations'].map { |t| t['translatable_type'] }
        expect(translatable_ids).to include motion.id
        expect(translatable_types).to include 'Motion'
      end

      it 'responds with an inline translation for a comment' do
        comment_translation
        get :inline, model: 'comment', id: comment.id, to: :fr
        json = JSON.parse(response.body)
        translatable_ids = json['translations'].map { |t| t['translatable_id'] }
        translatable_types = json['translations'].map { |t| t['translatable_type'] }
        expect(translatable_ids).to include comment.id
        expect(translatable_types).to include 'Comment'
      end

      it 'does not translate an unknown language' do
        get :inline, model: 'comment', id: comment.id, to: :wark
        expect(response.status).to eq 422
        json = JSON.parse(response.body)
        expect(json['errors'].keys).to include 'language'
      end

    end
  end

end
