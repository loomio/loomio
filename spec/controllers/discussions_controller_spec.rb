require 'rails_helper'

describe DiscussionsController do
  let(:discussion) { create :discussion }
  let(:user) { create :user }
  before { discussion.group.add_member! user }

  describe 'show' do
    it 'displays an xml feed' do
      get :show, key: discussion.key, format: :xml
      expect(response.status).to eq 200
      expect(assigns(:discussion)).to eq discussion
    end

    it 'displays an xml error when discussion is not found' do
      get :show, key: :notakey, format: :xml
      expect(response.status).to eq 404
    end
  end
end
