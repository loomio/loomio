require 'rails_helper'

describe DiscussionsController do
  let(:group) { create :group, is_visible_to_public: true }
  let(:discussion) { create :discussion, private: false, group: group }
  let(:user) { create :user }
  before { group.add_member! user }

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

    it 'sets metadata for public discussions' do
      get :show, key: discussion.key
      expect(assigns(:metadata)[:title]).to eq discussion.title
    end

    it 'does not set metadata for private discussions' do
      discussion.update(private: true)
      get :show, key: discussion.key
      expect(assigns(:metadata)[:title]).to be_nil
    end
  end
end
