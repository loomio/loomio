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

  context "users have voted" do
    before :each do
      @motion = create_motion
      user1 = User.make
      user1.save
      user2 = User.make
      user2.save
      user3 = User.make
      user3.save
      @motion.group.add_member!(user1)
      @motion.group.add_member!(user2)
      @motion.group.add_member!(user3)
      Vote.create!(position: 'yes', motion: @motion, user: user1)
      Vote.create!(position: 'no', motion: @motion, user: user2)
      Vote.create!(position: 'yes', motion: @motion, user: user3)
      @motion.close_voting
    end

    context "motion closed" do
      it "records and freezes no_vote_count" do
        @motion.no_vote_count.should == 2
        @motion.group.add_member!(User.make!)
        @motion.no_vote_count.should == 2
      end
    end

    context "motion re-opened" do
      before :each do
        @motion.open_voting
      end

      it "no_vote_count should not be frozen" do
        @motion.no_vote_count.should == 2
        @motion.group.add_member!(User.make!)
        @motion.no_vote_count.should == 3
      end
    end
  end
end
