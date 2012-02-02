require 'spec_helper'

describe MotionsController do
  context "signed in user, admin of a group" do
    before :each do
      @user = User.make!
      @group = Group.make!
      @group.add_admin!(@user)
      sign_in @user
    end

    it "can close a motion" do
      @motion = create_motion(group: @group)
      debugger
      @motion.phase.should == 'voting'
      post :close_voting, id: @motion.id
      @motion.phase.should == 'closed'
    end
  end

  context "signed in user, in a group" do
    before :each do
      @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
      sign_in @user
    end

    it "can create a motion" do
      @fuser = User.make!
      @motion_attrs = {:name => 'testing motions is a good idea', 
                       :facilitator_id => @fuser.id, :phase => 'voting'}
      post :create, :group_id => @group.id, :motion => @motion_attrs
      response.should be_redirect
      assigns(:motion).should be_valid
      assigns(:motion).group.should == @group
      assigns(:motion).facilitator.should == @facilitator
      assigns(:motion).phase.should == 'voting'
    end

    it "cannot close a motion" do
      @motion = create_motion(group: @group)
      @motion.phase.should == 'voting'
      post :close_voting, id: @motion.id
      @motion.phase.should == 'voting'
    end

    it "sends an email after motion creation to members of group" do
      @motion = Motion.make
      @motion.facilitator = User.make!
      @motion.author = User.make!
      @motion.group.add_member!(@motion.author)
      @motion.group.add_member!(@motion.facilitator)
      @motion.phase = 'voting'
      @motion.name = "Test Email"
      post :create, :group_id => @group.id, :motion => @motion.attributes
      last_email =  ActionMailer::Base.deliveries.last
      last_email.subject.should =~ /[Tautoko]/
    end

    it "can view a motion" do
      @motion = create_motion(group: @group)
      get :show, group_id: @motion.group.id, id: @motion.id
      response.should be_success
    end

    it "cannot edit a motion if they aren't the author or facilitator" do
      @motion = create_motion(group: @group)
      get :edit, id: @motion.id
      flash[:error].should =~ /Only the facilitator/
      response.should be_redirect
    end

    it "can delete a motion if they are the author" do
      motion = create_motion(author: @user, group: @group)
      delete :destroy, id: motion.id
      response.should be_redirect
      flash[:notice].should =~ /Motion deleted/
      @group.reload
      @group.motions.should_not include(motion)
    end

    it "can delete a motion if they are a group admin" do
      @group.add_admin!(@user)
      motion = create_motion(group: @group)
      delete :destroy, id: motion.id
      response.should be_redirect
      flash[:notice].should =~ /Motion deleted/
      @group.reload
      @group.motions.should_not include(motion)
    end

    it "cannot delete a motion if they are not a group admin or the author" do
      motion = create_motion(group: @group)
      delete :destroy, id: motion.id
      response.should be_redirect
      flash[:error].should =~ /You do not have significant priviledges to do that./
      @group.reload
      @group.motions.should include(motion)
    end

  end
end
