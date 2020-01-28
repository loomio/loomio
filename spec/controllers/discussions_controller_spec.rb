require 'rails_helper'

describe DiscussionsController do
  let(:group) { create :formal_group, is_visible_to_public: true }
  let(:discussion) { create :discussion, private: true, group: group }
  let(:user) { create :user }

  describe 'show' do
    it '200, ssr + boot' do
      group.add_member! user
      sign_in user
      get :show, params: { key: discussion.key }
      expect(response.status).to eq 200
      expect(assigns(:discussion)).to eq discussion
    end

    it 'not logged in, 403, ssr + boot' do
      get :show, params: { key: discussion.key }
      expect(response.status).to eq 403
      expect(assigns(:discussion)).to eq nil
    end

    it 'not member, 403, ssr + boot' do
      sign_in user
      get :show, params: { key: discussion.key }
      expect(response.status).to eq 403
      expect(assigns(:discussion)).to eq nil
    end

    it '404 ssr only' do
      get :show, params: { key: 'doesnotexist'}
      expect(response.status).to eq 404
      expect(assigns(:discussion)).to eq nil
    end

    it 'signed in, displays an xml feed' do
      group.add_member! user
      sign_in user
      get :show, params: { key: discussion.key }, format: :xml
      expect(response.status).to eq 200
      expect(assigns(:discussion)).to eq discussion
    end
    it 'signed out, displays an xml feed' do
      discussion.update(private: false)
      get :show, params: { key: discussion.key }, format: :xml
      expect(response.status).to eq 200
      expect(assigns(:discussion)).to eq discussion
    end

    # it 'sets metadata for public discussions' do
    #   get :show, params: { key: discussion.key }
    #   expect(assigns(:metadata)[:title]).to eq discussion.title
    # end

    # it 'does not set metadata for private discussions' do
    #   discussion.update(private: true)
    #   get :show, params: { key: discussion.key }
    #   expect(assigns(:metadata)[:title]).to be_nil
    # end
  end
end
