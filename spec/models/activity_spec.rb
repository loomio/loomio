require 'spec_helper'

describe Activity do
  before :each do
    @user = User.make
    @user.save
    @motion = create_motion
    @motion.group.add_member!(@user)
  end
  #it {should have(1).errors_on(:activity_count)}
  #it {should have(1).errors_on(:user_id)}
  #it {should have(1).errors_on(:motion_id)}

  #it "user_has_votes?(user) returns true if the given user has voted on motion" do
    #@user = User.make!
    #@motion = create_motion(:author => @user)
    #@vote = Vote.make(:user => @user, :motion => @motion, :position => "yes")
    #@vote.save!
    #@motion.user_has_voted?(@user).should == true
  #end
end
