require 'spec_helper'

describe GroupsController do
  let(:group) { create :group }
  let(:user)  { create :user }

  context 'signed out' do
    context "group viewable by everyone" do
      before { group.update_attribute(:viewable_by, 'everyone') }

      it "show" do
        get :show, :id => group.id
        response.should be_success
      end
    end

    context "group viewable by members" do
      before { group.update_attribute('viewable_by', 'members') }
      it "does not show" do
        get :show, :id => group.id
        response.should be_redirect
      end
    end
  end

  context "group viewable by members" do
    before do 
      group.update_attribute('viewable_by', 'members')
      group.add_member!(user)
      sign_in user
    end

    it "show" do
      get :show, :id => group.id
      response.should be_success
    end

    it "add_subgroup" do
      get :add_subgroup, :id => group.id
      response.should be_success
    end

    it "create subgroup" do
      post :create, :group => {parent_id: group.id, name: 'subgroup'}
      assigns(:group).parent.should eq(group)
      assigns(:group).admins.should include(user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    it "add_members" do
      added_user = create(:user)
      post :add_members, id: group.id, "user_#{added_user.id}" => 1
      group.members.should include added_user
    end

    context "a group admin" do
      before { group.add_admin!(user) }

      it "update" do
        post :update, id: group.id, group: { name: "New name!" }
        flash[:notice].should == "Group was successfully updated."
        response.should redirect_to group
      end

      describe "#edit description" do
        it "assigns description and saves model" do
          xhr :post, :edit_description, :id => group.id, :description => "blah"
          assigns(:group).description.should == 'blah'
        end
      end

      describe "#edit privacy" do
        it "assigns viewable_by and saves" do
          xhr :post, :edit_privacy, :id => group.id, :viewable_by => "everyone"
          assigns(:group).viewable_by.should == 'everyone'
        end
      end

      describe "archives group" do
        before { put :archive, :id => group.id }

        it "sets archived_at field on the group" do
          assigns(:group).archived_at.should_not == nil
        end

        it "sets flash and redirects to the dashboard" do
          flash[:success].should =~ /Group archived successfully/
          response.should redirect_to '/'
        end
      end
    end
  end

  describe "viewing an archived group" do
    render_views
    before { group.archive! }

    it "should render the page not found template" do
      get :show, :id => group.id
      response.should render_template('application/display_error', message: I18n.t('error.group_private_or_not_found'))
    end
  end

end
