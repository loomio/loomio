require 'spec_helper'

describe VotesController do
  context 'a signed in user voting on a motion' do
    before :each do
      sign_in @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
      @motion = create_motion(:group => @group, :phase => 'voting')
      @motion.save!
    end
    it 'can vote' do
      post :create, :motion_id => @motion.id, 
           :vote => {:position => 'yes', :statement => 'blah'}
      response.should be_redirect
      flash[:notice].should =~ /Vote was successfully created/
      assigns(:vote).user.should == @user
      assigns(:vote).motion.should == @motion
      assigns(:vote).position.should == 'yes'
      assigns(:vote).statement.should == 'blah'
    end
    
    it 'can only vote in voting phase' do
      @motion = create_motion(:group => @group, :phase => 'closed')
      post :create, :motion_id => @motion.id, 
           :vote => {:position => 'yes', :statement => 'blah'}
      response.should be_redirect
      flash[:notice].should =~ /Can only vote in voting phase/
    end
  end
end
