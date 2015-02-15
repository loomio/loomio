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
        response.should be_success
      end
    end

    context "hidden group" do
      before { group.update_attribute(:is_visible_to_public, false) }
      it "does not show" do
        get :show, :id => group.key
        response.should be_redirect
      end
    end
  end

  context "hidden group" do
    before do
      group.update_attribute(:is_visible_to_public, false)
      group.add_member!(user)
      sign_in user
    end

    it "show" do
      get :show, :id => group.key
      response.should be_success
    end

    it "add_subgroup" do
      get :add_subgroup, :id => group.key
      response.should be_success
    end

    it "create subgroup" do
      post :create, :group => {parent_id: group.id, name: 'subgroup', is_visible_to_public: false}
      expect(assigns(:group).parent).to eq (group)
      assigns(:group).admins.should include(user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    context "a group admin" do
      before { group.add_admin!(user) }

      it "update" do
        expected_new_path = group_path(group).gsub(group.full_name.parameterize, 'new-name')
        post :update, id: group.key, group: { name: "New name!" }
        expect(flash[:notice]).to eq "Group was successfully updated."
        response.should redirect_to expected_new_path
      end

      describe "archives group" do
        before { put :archive, :id => group.key }

        it "sets archived_at field on the group" do
          assigns(:group).archived_at.should_not == nil
        end

        it "sets flash and redirects to the dashboard" do
          expect(flash[:success]).to match(/Group archived successfully/)
          response.should redirect_to '/dashboard'
        end
      end
    end
  end
end
