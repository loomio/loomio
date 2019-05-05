require 'rails_helper'

describe GroupsController do
  let(:group) { create :formal_group }
  let(:guest_group) { create :guest_group }
  let(:user) { create :user }
  before { group.add_member! user }

  describe 'show' do
    it 'displays an xml feed' do
      get :show, params: { key: group.key }, format: :rss
      expect(response.status).to eq 200
      expect(assigns(:group)).to eq group
    end

    it 'displays an xml error when group is not found' do
      get :show, params: { key: :notakey }, format: :rss
      expect(response.status).to eq 404
    end
  end

  describe 'export' do
    it 'loads an export' do
      sign_in user
      group.add_admin! user
      get :export, params: { key: group.key }, format: :html
      expect(response.status).to eq 200

      get :export, params: { key: group.key }, format: :csv
      expect(response.status).to eq 200
    end

    it 'does not allow non-admins to see export' do
      sign_in user
      get :export, params: { key: group.key }, format: :html
      expect(response.status).to eq 302

      get :export, params: { key: group.key }, format: :csv
      expect(response.status).to eq 302
    end
  end
end
