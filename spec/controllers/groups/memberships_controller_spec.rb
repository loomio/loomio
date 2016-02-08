require 'rails_helper'

describe Groups::MembershipsController do

  describe 'index' do
    before do
      @user = create(:user)
      sign_in @user
      @group = create(:group)
    end

    it 'allows access to group members' do
      @group.add_member! @user
      get :index, group_id: @group.key
      expect(response).to be_success
    end

    it 'does not allow access to non-group members' do
      get :index, group_id: @group.key
      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end
  end

  context 'signed in user' do
    before :each do
      @user = create(:user)
      sign_in @user
      @new_user = create(:user)
      @group = create(:group)
      request.env["HTTP_REFERER"] = group_url(@group)
    end

    context 'group admin' do
      before :each do
        @group.add_admin!(@user)
      end

      it "can edit a user" do
        membership = @group.add_member!(@new_user)
        get :edit, :group_id => @group.id, :id => membership.id
      end

      it 'can add an admin' do
        @membership = @group.add_member!(@new_user)
        post :make_admin, :id => @membership.id, group_id: @group.id
        expect(flash[:notice]).to match(/#{@new_user.name} has been made a coordinator./)
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).admin.should be true
        @group.admins.reload.should include(@new_user)
      end

      context "removes a member" do
        before do
          @group.add_member!(@new_user)
          @membership = @group.memberships.find_by_user_id(@new_user.id)
          delete :destroy, :id => @membership.id, :group_id => @group.id
        end
        it { expect(flash[:notice]).to match(/Member removed/) }
        it { response.should redirect_to group_memberships_path(@membership.group)}
        it { @group.users.should_not include(@new_user) }
      end

      it 'cannot remove an admin' do
        @membership = @group.add_admin!(@new_user)
        post :remove_admin, :id => @membership.id, group_id: @group.id
        expect(flash[:notice]).to match(/#{@membership.user_name}'s coordinator rights have been removed./)
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).admin.should be false
        @group.admins.should_not include(@new_user)
      end
    end
  end
end
