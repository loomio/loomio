require 'spec_helper'

describe MembershipsController do
  context 'signed in user' do
    before :each do
      @user = User.make!
      sign_in @user
    end

    it "requests membership to a group" do
      @group = Group.make!
      # note trying to sneek member level access.. should be ignored
      post :create, 
           :membership => {:group_id => @group.id, :access_level => 'member'}
      response.should redirect_to(groups_path)
      assigns(:membership).user.should == @user
      assigns(:membership).group.should == @group
      assigns(:membership).access_level.should == 'request'
    end

    context 'group member' do
      before :each do
        @group = Group.make!
        @group.add_member!(@user)
      end

      it "can authorize a membership request for another user" do
        @new_user = User.make!
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id, 
             :membership => {:access_level => 'member'}
        flash[:notice].should =~ /Membership approved/
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'member'
        assigns(:membership).id.should == @membership.id
      end

      it "can ignore a membership request for another user" do
        @new_user = User.make!
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        delete :destroy, :id => @membership.id
        flash[:notice].should =~ /Membership ignored/
        response.should redirect_to(@group)
        Membership.all().should_not include?(@membership)
      end
    end

    context 'non group member' do
      before :each do
        @group = Group.make!
      end

      it "cannot authorize a membership request for another user" do
        @new_user = User.make!
        @group.add_request!(@new_user)
        @membership = @group.membership_requests.first
        post :update, :id => @membership.id, 
             :membership => {:access_level => 'member'}
        flash[:error].should =~ /Membership not approved/
        response.should redirect_to(@group)
        assigns(:membership).access_level.should == 'request'
        assigns(:membership).id.should == @membership.id
      end
    end
  end
end
