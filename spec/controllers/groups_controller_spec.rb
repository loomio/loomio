require 'rails_helper'

describe GroupsController do
  let(:group) { create :group }
  let(:user) { create :user }
  before { group.add_member! user }

  describe 'show' do
    it 'displays an xml feed' do
      get :show, key: group.key, format: :xml
      expect(response.status).to eq 200
      expect(assigns(:group)).to eq group
    end

    it 'displays an xml error when group is not found' do
      get :show, key: :notakey, format: :xml
      expect(response.status).to eq 404
    end
  end
end
