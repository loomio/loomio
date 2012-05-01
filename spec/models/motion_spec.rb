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

  it "sends notification email to group members on successful create" do
    group = Group.make!
    group.add_member!(User.make!)
    group.add_member!(User.make!)
    # Do not send email to author, so subtract one from total emails sent
    MotionMailer.should_receive(:new_motion_created)
      .exactly(group.users.count - 1).times
      .with(kind_of(Motion), kind_of("")).and_return(stub(deliver: true))
    @motion = create_motion
  end

  it "cannot have invalid phases" do
    @motion = create_motion
    @motion.phase = 'bad'
    @motion.should_not be_valid
  end

  it "it can remain un-blocked" do
    @motion = create_motion
    user1 = User.make
    user1.save
    @motion.group.add_member!(user1)
    Vote.create!(position: 'yes', motion: @motion, user: user1)
    @motion.blocked?.should == false
  end

  it "it can be blocked" do
    @motion = create_motion
    user1 = User.make
    user1.save
    @motion.group.add_member!(user1)
    Vote.create!(position: 'block', motion: @motion, user: user1)
    @motion.blocked?.should == true
  end

  it "can have a close date" do
    @motion = create_motion
    @motion.close_date = '2012-12-12'
    @motion.close_date.should == Date.parse('2012-12-12')
    @motion.should be_valid
  end

  it "can have a discussion link" do
    @motion = create_motion
    @motion.discussion_url = "http://our-discussion.com"
    @motion.should be_valid
  end

  it "can have a discussion" do
    @motion = create_motion
    @motion.save
    @motion.discussion.should_not be_nil
  end

  it "can update vote_activity" do
    @motion = create_motion
    @motion.vote_activity = 3
    @motion.update_vote_activity
    @motion.vote_activity.should == 4
  end

  it "can update discussion_activity" do
    @motion = create_motion
    @motion.discussion_activity = 3
    @motion.update_discussion_activity
    @motion.discussion_activity.should == 4
  end

  context "move motion to new group" do
    before do
      @new_group = Group.make!
      @motion = create_motion
      @motion.move_to_group @new_group
      @motion.save
    end

    it "changes motion group_id to new group" do
      @motion.group.should == @new_group
    end

    it "changes motion discussion_id to new group" do
      @motion.discussion.group.should == @new_group
    end
  end

  context "closed motion" do
    before :each do
      user1 = User.make
      user1.save
      user2 = User.make
      user2.save
      @user3 = User.make
      @user3.save
      @motion = create_motion(author: user1, facilitator: user1)
      @motion.group.add_member!(user1)
      @motion.group.add_member!(user2)
      @motion.group.add_member!(@user3)
      Vote.create!(position: 'yes', motion: @motion, user: user1)
      Vote.create!(position: 'no', motion: @motion, user: user2)
      @motion.close_voting!
    end

    it "stores users who did not vote" do
      DidNotVote.first.user.should == @user3
    end

    it "no_vote_count should return number of users who did not vote" do
      @motion.no_vote_count.should == 1
    end

    it "users_who_did_not_vote should return users who did not vote" do
      @motion.users_who_did_not_vote.should include(@user3)
    end

    it "reopening motion deletes did_not_vote records" do
      @motion.open_voting
      DidNotVote.all.count.should == 0
    end
  end

  context "open motion" do
    before :each do
      @user1 = User.make
      @user1.save
      @motion = create_motion(author: @user1, facilitator: @user1)
    end

    it "no_vote_count should return number of users who have not voted yet" do
      @motion.no_vote_count.should == 1
    end

    it "users_who_did_not_vote should return users who did not vote" do
      @motion.users_who_did_not_vote.should include(@user1)
    end

  end
end
