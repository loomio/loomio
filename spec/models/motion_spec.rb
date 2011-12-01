require 'spec_helper'

describe Motion do
  subject do
    @motion = Motion.new
    @motion.valid?
    @motion
  end
  it {should have(1).errors_on(:name)}
  it {should have(1).errors_on(:author)}
  it {should have(1).errors_on(:group)}

  it "user_has_votes?(user) returns true if the given user has voted on motion" do
    #This works when running as single spec, but not if in all specs, WTF
    @user = User.make
    @user.save!
    @group = Group.make
    @group.save!
    @group.add_member!(@user)
    @group.save!
    @motion_to_vote_on = Motion.make(:group => @group, :facilitator => @user, :author => @user)
    @motion_to_vote_on.save!
    @vote = Vote.make(:user => @user, :motion => @motion_to_vote_on, :position => "yes")
    @vote.save!
    @motion_to_vote_on.user_has_voted?(@user).should == true
  end
end
