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
  it {should have(1).errors_on(:facilitator_id)}

  it "user_has_votes?(user) returns true if the given user has voted on motion" do
    @user = User.make!
    @motion = create_motion(:author => @user)
    @vote = Vote.make(:user => @user, :motion => @motion, :position => "yes")
    @vote.save!
    @motion.user_has_voted?(@user).should == true
  end

  it "cannot have invalid phases" do
    @motion = create_motion
    @motion.phase = 'bad'
    @motion.should_not be_valid
  end

  it "has a discussion link" do
    @motion = create_motion
    @motion.discussion_url = "http://our-discussion.com"
    @motion.should be_valid
  end
end
