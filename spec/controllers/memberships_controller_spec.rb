require 'spec_helper'

describe MembershipsController do
  context 'signed in user' do
    before :each do
      @user = User.make!
      sign_in @user
      @new_user = User.make!
      @group = Group.make!
      request.env["HTTP_REFERER"] = group_url(@group)
    end

    context "requests membership to a group visible to members" do
      it "should succeed and redirect to groups index page" do
        @group.update_attributes({viewable_by: :members})
        # note trying to sneek member level access.. should be ignored
        post :create,
             :membership => {:group_id => @group.id, :access_level => 'member'}
        response.should redirect_to(root_url)
        assigns(:group).requested_users.should include(@user)
      end
    end

    context "requests membership to a group visible to everyone" do
      it "should succeed and redirect to group show page" do
        post :create, :membership => {:group_id => @group.id}
        response.should redirect_to(group_url(@group))
        assigns(:group).requested_users.should include(@user)
      end
    end

    context "cancels their own membership request" do
      before do
        membership = @group.add_request!(@user)
        delete :cancel_request, :id => membership.id
      end
      it "removes membership request from group" do
        @group.requested_users.should_not include(@user)
      end
      it "gives flash success notice" do
        flash[:notice].should =~ /Membership request canceled/
      end
      it "redirects to group page" do
        response.should redirect_to(@group)
      end
    end

    it "sends an email to admins with new membership request" do
      GroupMailer.should_receive(:new_membership_request).and_return(stub(deliver: true))
      @group.add_admin!(User.make!)
      post :create,
           :membership => {:group_id => @group.id}
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
        post :make_admin, :id => @membership.id
        flash[:notice].should =~ /#{@new_user.name} has been made an admin./
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'admin'
        @group.admins.should include(@new_user)
      end

      it 'can remove a member' do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:notice].should =~ /Member removed/
        response.should redirect_to(@group)
        @group.users.should_not include(@new_user)
      end

      it 'cannot remove an admin' do
        @membership = @group.add_admin!(@new_user)
        post :remove_admin, :id => @membership.id
        flash[:notice].should =~ /#{@membership.user_name}'s admin rights have been removed./
        response.should redirect_to(group_url(@group))
        assigns(:membership).access_level.should == 'member'
        @group.admins.should_not include(@new_user)
      end
    end

    context 'group member' do
      before :each do
        @group.add_member!(@user)
      end

      context "approves a membership request" do
        before do
          @membership = @group.add_request!(@new_user)
        end
        it "adds membership to group" do
          post :approve_request, :id => @membership.id
          @group.users.should include(@new_user)
        end
        it "gives flash success notice" do
          post :approve_request, :id => @membership.id
          flash[:notice].should =~ /Membership approved/
        end
        it "redirects to group" do
          post :approve_request, :id => @membership.id
          response.should redirect_to(@group)
        end
        it "sends an email to notify the user of their membership approval" do
          UserMailer.should_receive(:group_membership_approved).and_return(stub(deliver: true))
          post :approve_request, :id => @membership.id
        end
        it "does not send a notification email if member is already approved" do
          @membership = @group.add_member!(@new_user)
          UserMailer.should_not_receive(:group_membership_approved).and_return(stub(deliver: true))
          post :approve_request, :id => @membership.id
        end
      end

      it 'cannot add an admin' do
        @membership = @group.add_member!(@new_user)
        post :make_admin, :id => @membership.id
        flash[:error].should =~ /Access denied./
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'member'
        @group.admins.should_not include(@new_user)
      end

      it "can ignore a membership request" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        delete :ignore_request, :id => @membership.id
        flash[:notice].should =~ /Membership request ignored/
        response.should redirect_to(@group)
        Membership.exists?(@membership).should be_false
      end

      it "cannot remove a member" do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(group_url(@group))
        @group.users.should include(@new_user)
      end

      it "cannot remove an admin" do
        @membership = @group.add_admin!(@new_user)
        post :remove_admin, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(group_url(@group))
        @group.admins.should include(@new_user)
      end
    end

    context 'non group member' do
      it "cannot authorize a membership request for another user" do
        @membership = @group.add_request!(@new_user)
        post :approve_request, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(group_url(@group))
        assigns(:membership).access_level.should == 'request'
        assigns(:membership).id.should == @membership.id
      end

      it "cannot remove a member" do
        @membership = @group.add_member!(@new_user)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(group_url(@group))
        @group.users.should include(@new_user)
      end

      it "cannot remove an admin" do
        @group.add_admin!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(group_url(@group))
        @group.admins.should include(@new_user)
      end
    end
  end
end
