require 'rails_helper'

describe GroupsController do
  let(:group) { create :formal_group }
  let(:guest_group) { create :guest_group }
  let(:user) { create :user }

  describe 'index' do
    it 'works' do
      get :index
      expect(response.status).to eq 200
    end
  end

  describe 'show' do
    describe 'secret' do
      before { group.update(group_privacy: 'secret')}
      it '200, ssr + boot' do
        group.add_member! user
        sign_in user
        get :show, params: { key: group.key }
        expect(response.status).to eq 200
        expect(assigns(:group)).to eq group
      end

      it 'not logged in, 403, ssr + boot' do
        get :show, params: { key: group.key }
        expect(response.status).to eq 403
        expect(assigns(:group)).to eq nil
      end

      it 'not member, 403, ssr + boot' do
        sign_in user
        get :show, params: { key: group.key }
        expect(response.status).to eq 403
        expect(assigns(:group)).to eq nil
      end

      it '404 ssr only' do
        get :show, params: { key: 'doesnotexist'}
        expect(response.status).to eq 404
        expect(assigns(:group)).to eq nil
      end
    end

    describe 'closed' do
      before { group.update(group_privacy: 'closed')}

      it '200, ssr + boot' do
        group.add_member! user
        sign_in user
        get :show, params: { key: group.key }
        expect(response.status).to eq 200
        expect(assigns(:group)).to eq group
      end

      it 'not logged in, 403, ssr + boot' do
        get :show, params: { key: group.key }
        expect(response.status).to eq 200
        expect(assigns(:group)).to eq group
      end

      it 'not member, 403, ssr + boot' do
        sign_in user
        get :show, params: { key: group.key }
        expect(response.status).to eq 200
        expect(assigns(:group)).to eq group
      end

      it '404 ssr only' do
        get :show, params: { key: 'doesnotexist'}
        expect(response.status).to eq 404
        expect(assigns(:group)).to eq nil
      end
    end

    it 'signed in, displays an xml feed' do
      group.add_member! user
      sign_in user
      get :show, params: { key: group.key }, format: :xml
      expect(response.status).to eq 200
      expect(assigns(:group)).to eq group
    end

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
