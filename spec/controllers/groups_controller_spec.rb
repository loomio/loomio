require 'rails_helper'

describe GroupsController do
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group}
  let(:user)  { create :user }

  context 'signed out' do
    context "public group" do
      before { group.update_attribute(:is_visible_to_public, true) }

      it "show" do
        get :show, :id => group.key
        expect(response).to be_success
      end

      it 'should not error on sifting unread' do
        get :show, id: group.key, unread: "true"
        expect(response).to be_success
      end

      it 'should not error on sifting followed' do
        get :show, id: group.key, followed: "true"
        expect(response).to be_success
      end
    end

    context "hidden group" do
      before { group.update_attribute(:is_visible_to_public, false) }
      it "does not show" do
        sign_in user
        get :show, :id => group.key
        expect(response).to be_redirect
      end
    end
  end

  context "hidden group" do
    before do
      group.update_attributes(is_visible_to_public: false, members_can_create_subgroups: true)
      group.add_member!(user)
      sign_in user
    end

    it "show" do
      get :show, :id => group.key
      expect(response).to be_success
    end

    it "add_subgroup" do
      get :add_subgroup, :id => group.key
      expect(response).to be_success
    end

    it "create subgroup" do
      post :create, :group => {parent_id: group.id, name: 'subgroup', is_visible_to_public: false}
      expect(assigns(:group).parent).to eq (group)
      expect(assigns(:group).admins).to include(user)
      expect(response).to redirect_to(group_url(assigns(:group)))
    end

    context "a group admin" do
      before { group.add_admin!(user) }

      it "update" do
        expected_new_path = group_path(group).gsub(group.full_name.parameterize, 'new-name')
        post :update, id: group.key, group: { name: "New name!" }
        expect(flash[:notice]).to eq "Group was successfully updated."
        expect(response).to redirect_to expected_new_path
      end

      describe "archives group" do
        before { put :archive, :id => group.key }

        it "sets archived_at field on the group" do
          expect(assigns(:group).archived_at).to_not be_nil
        end

        it "sets flash and redirects to the dashboard" do
          expect(flash[:success]).to match(/Group archived successfully/)
          expect(response).to redirect_to '/dashboard'
        end
      end
    end
  end
end
