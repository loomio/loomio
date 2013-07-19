require 'spec_helper'

describe Groups::MembershipsController do
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
        get :edit, :id => membership.id
      end

      it 'can add an admin' do
        @membership = @group.add_member!(@new_user)
        post :make_admin, :id => @membership.id, group_id: @group.id
        flash[:notice].should =~ /#{@new_user.name} has been made a coordinator./
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).access_level.should == 'admin'
        @group.admins.should include(@new_user)
      end

      context "removes a member" do
        before do
          @group.add_member!(@new_user)
          @membership = @group.memberships.find_by_user_id(@new_user.id)
          delete :destroy, :id => @membership.id
        end
        it { flash[:notice].should =~ /Member removed/ }
        it { response.should redirect_to group_memberships_path(@group) }
        it { @group.users.should_not include(@new_user) }

        context "that was already removed" do
          before { delete :destroy, :id => @membership.id }

          it { response.should redirect_to(@group) }
        end
      end

      it 'cannot remove an admin' do
        @membership = @group.add_admin!(@new_user)
        post :remove_admin, :id => @membership.id, group_id: @group.id
        flash[:notice].should =~ /#{@membership.user_name}'s coordinator rights have been removed./
        response.should redirect_to(group_memberships_path(@group))
        assigns(:membership).access_level.should == 'member'
        @group.admins.should_not include(@new_user)
      end
    end
  end
end
