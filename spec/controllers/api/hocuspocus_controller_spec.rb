require 'rails_helper'

describe Api::HocuspocusController do
  let(:user)  { create :user, name: 'user' }
  let(:discussion)  { create :discussion, author: user }
  let(:other_discussion)  { create :discussion }

  before do
    user.reload
  end

  describe 'logged out user' do
    # we allow logged out users to create groups from a template
    # but not anything else
    it 'allows new groups' do
      post :create, params: {
        user_secret: "0,anything at all",
        document_name: "group-new-#{user.id}-1-1-1"
      }
      expect(response.status).to eq 200
    end

    it 'denies non groups' do
      post :create, params: {
        user_secret: "0,anything at all",
        document_name: "discussion-new-#{user.id}-1-1-1"
      }
      expect(response.status).to eq 401
    end
  end

  describe 'new comment' do
    it 'valid secret_token returns 200' do
      post :create, params: {
        user_secret: "#{user.id},#{user.secret_token}",
        document_name: "comment-new-#{user.id}-1-1-1"
      }
      expect(response.status).to eq 200
    end

    it 'invalid secret_token returns 401' do
      post :create, params: {
        user_secret: "#{user.id},1203987120983120",
        document_name: "comment-new-#{user.id}-1-1-1"
      }
      expect(response.status).to eq 401
    end

    it 'wrong user_id returns 401' do
      post :create, params: {
        user_secret: "#{user.id}1,#{user.secret_token}",
        document_name: "comment-new-#{user.id}-1-1-1"
      }
      expect(response.status).to eq 401
    end

    it 'wrong user_id in document returns 401' do
      post :create, params: {
        user_secret: "#{user.id},#{user.secret_token}",
        document_name: "comment-new-#{user.id}1-1-1-1"
      }
      expect(response.status).to eq 401
    end
  end

  describe "exising discussion" do
    it 'valid secret_token returns 200' do
      post :create, params: {
        user_secret: "#{user.id},#{user.secret_token}",
        document_name: "discussion-#{discussion.id}-description"
      }
      expect(response.status).to eq 200
    end

    it 'invalid secret_token returns 401' do
      post :create, params: {
        user_secret: "#{user.id},#{user.secret_token}12",
        document_name: "discussion-#{discussion.id}-description"
      }
      expect(response.status).to eq 401
    end

    it 'other discussion returns 401' do
      post :create, params: {
        user_secret: "#{user.id},#{user.secret_token}",
        document_name: "discussion-#{other_discussion.id}-description"
      }
      expect(response.status).to eq 401
    end
  end
end
