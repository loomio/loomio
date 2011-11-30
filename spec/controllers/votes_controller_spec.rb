require 'spec_helper'

describe VotesController do
  context 'a signed in user' do
    before :each do
      sign_in @user = User.make!
    end
    it 'votes on a motion' do
      @group = Group.make!
      @group.add_member!(@user)
      @motion = create_motion(:group => @group)
      @motion.save!
      post :create, :vote => {:motion_id => @motion.id,
                              :position => 'yes'}
      response.should be_redirect
      flash[:notice].should =~ /Vote saved/
      assigns(:vote).user.should == @user
      assigns(:vote).motion.should == @motion
      assigns(:vote).position.should == 'yes'
    end
  end
end
