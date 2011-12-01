require 'spec_helper'

describe VotesController do
  context 'a signed in user voting on a motion' do
    before :each do
      sign_in @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
      @motion = create_motion(:group => @group)
      @motion.save!
    end
    it 'can vote' do
      post :create, :motion_id => @motion.id, 
           :vote => {:position => 'yes', :statement => 'blah'}
      response.should be_redirect
      flash[:notice].should =~ /Vote saved/
      assigns(:vote).user.should == @user
      assigns(:vote).motion.should == @motion
      assigns(:vote).position.should == 'yes'
      assigns(:vote).statement.should == 'blah'
    end

    it 'cannot vote multiple times' do
      post :create, :motion_id => @motion.id, 
           :vote => {:position => 'yes'}
      response.should be_redirect
      post :create, :motion_id => @motion.id, 
           :vote => {:position => 'no'}
      flash[:error].should =~ /Only one vote is allowed per user/
      assigns(:vote).user.should == @user
      assigns(:vote).motion.should == @motion
      assigns(:vote).position.should == 'yes'
      votes = Vote.where("user_id = ? AND motion_id = ?", 
                         @user.id, @motion.id)
    end
  end
end
