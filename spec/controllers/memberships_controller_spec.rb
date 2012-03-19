require 'spec_helper'

describe MembershipsController do
  context 'signed in user' do
    before :each do
      @user = User.make!
      sign_in @user
      @new_user = User.make!
      @group = Group.make!
    end

    it "requests membership to a group" do
      # note trying to sneek member level access.. should be ignored
      post :create,
           :membership => {:group_id => @group.id, :access_level => 'member'}
      response.should redirect_to(groups_path)
      assigns(:group).requested_users.should include(@user)
    end

    it "sends an email to admins with new membership request" do
      @group.add_admin!(User.make!)
      post :create,
           :membership => {:group_id => @group.id}
      last_email =  ActionMailer::Base.deliveries.last
      last_email.to.should == @group.admins.map(&:email)
      last_email.subject.should include("[Loomio: #{@group.name}] Membership waiting approval.")
    end

    context 'group admin' do
      before :each do
        @group.add_admin!(@user)
      end

      it "can authorize a membership request" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id,
             :membership => {:access_level => 'member'}
        flash[:notice].should =~ /Membership approved/
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'member'
        assigns(:membership).id.should == @membership.id
      end

      it "sends an email to notify the user of their membership approval" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        UserMailer.should_receive(:group_membership_approved).and_return(stub(deliver: true))
        post :update, :id => @membership.id,
             :membership => {:access_level => 'member'}
        flash[:notice].should =~ /Membership approved/
      end

      it 'can add an admin' do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user)
        post :update, :id => @membership.id,
             :membership => {:access_level => 'admin'}
        flash[:notice].should =~ /Membership was successfully updated/
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'admin'
        @group.admins.should include(@new_user)
      end

      it 'can remove a member' do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:notice].should =~ /Membership deleted/
        response.should redirect_to(@group)
        @group.users.should_not include(@new_user)
      end

      it 'cannot remove an admin' do
        @group.add_admin!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.admins.should include(@new_user)
      end
    end

    context 'group member' do
      before :each do
        @group.add_member!(@user)
      end

      it "can authorize a membership request" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id,
             :membership => {:access_level => 'member'}
        flash[:notice].should =~ /Membership approved/
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'member'
        assigns(:membership).id.should == @membership.id
      end

      it "cannot change a membership request to an admin" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id,
             :membership => {:access_level => 'admin'}
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        assigns(:membership).access_level.should == 'request'
        assigns(:membership).id.should == @membership.id
      end

      it "can ignore a membership request" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        delete :destroy, :id => @membership.id
        flash[:notice].should =~ /Membership deleted/
        response.should redirect_to(@group)
        Membership.exists?(@membership).should be_false
      end

      it "cannot remove a member" do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.users.should include(@new_user)
      end

      it "cannot delete an admin" do
        @group.add_admin!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.admins.should include(@new_user)
      end

      it "cannot change a member's access level" do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        post :update, :id => @membership.id,
             :membership => {:access_level => 'admin'}
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.admins.should_not include(@new_user)
      end
    end

    context 'non group member' do
      it "cannot authorize a membership request for another user" do
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id,
             :membership => {:access_level => 'member'}
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        assigns(:membership).access_level.should == 'request'
        assigns(:membership).id.should == @membership.id
      end

      it "cannot remove a member" do
        @group.add_member!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.users.should include(@new_user)
      end

      it "cannot remove an admin" do
        @group.add_admin!(@new_user)
        @membership = @group.memberships.find_by_user_id(@new_user.id)
        delete :destroy, :id => @membership.id
        flash[:error].should =~ /Access denied/
        response.should redirect_to(root_url)
        @group.admins.should include(@new_user)
      end
    end
  end
end
