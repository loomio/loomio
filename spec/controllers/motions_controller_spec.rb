require 'spec_helper'

describe MotionsController do
  context "signed in user, in a group" do
    before :each do
      @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
      sign_in @user
    end

    it "creates a motion" do
      @fuser = User.make!
      @motion_attrs = {:name => 'testing motions is a good idea', 
                       :facilitator_id => @fuser.id}
      post :create, :group_id => @group.id, :motion => @motion_attrs
      response.should be_redirect
      assigns(:motion).should be_valid
      assigns(:motion).group.should == @group
      assigns(:motion).facilitator.should == @facilitator
    end
  end
end
