require 'spec_helper'

describe Motion do
  it { should have_many(:events).dependent(:destroy) }

  subject do
    @motion = Motion.new
    @motion.valid?
    @motion
  end
  it {should have(1).errors_on(:name)}
  it {should have(1).errors_on(:author)}

  it "user_has_voted?(user) returns true if the given user has voted on motion" do
    @user = create(:user)
    @motion = create(:motion, :author => @user)
    @vote = build(:vote,:position => "yes")
    @vote.user = @user
    @vote.motion = @motion
    @vote.save!
    @motion.user_has_voted?(@user).should == true
  end

  it "user_has_voted?(user) returns false if given nil" do
    @motion = create(:motion)
    @motion.user_has_voted?(nil).should == false
  end

  describe "#set_close_date(date)" do
    before do
      @motion = create(:motion)
    end
    context "date is a future date" do
      it "updates close_date" do
        future_date = 2.days.from_now
        @motion.set_close_date!(future_date)
        @motion.close_date.should == future_date
      end
    end
    context "date is a past date" do
      it "does not update close_date" do
        past_date = 2.days.ago
        @motion.set_close_date!(past_date)
        @motion.close_date.should_not  == past_date
      end
    end
  end

  context "events" do
    before do
      @user = create :user
      @group = create :group
      @group.add_admin! @user
      @discussion = create :discussion, :group => @group
    end
    it "fires new_motion event if a motion is created successfully" do
      motion = Motion.new
      motion.name = "That we create me"
      motion.author = @user
      motion.discussion = @discussion
      motion.should_receive(:fire_new_motion_event)
      motion.save!
    end
    it "adds motion closed activity if a motion is closed" do
      motion = create :motion, :discussion => @discussion
      Events::MotionClosed.should_receive(:publish!)
      motion.close_motion!(@user)
    end
    it "adds edit motion close date activity if a motion close date is edited" do
      motion = create :motion, :discussion => @discussion
      motion.should_receive(:fire_motion_close_date_edited_event).with(@user)
      motion.set_close_date!(2.days.from_now, @user)
    end
  end

  it "cannot have invalid phases" do
    @motion = create(:motion)
    @motion.phase = 'bad'
    @motion.should_not be_valid
  end

  it "it can remain un-blocked" do
    @motion = create(:motion)
    user1 = build(:user)
    user1.save
    @motion.group.add_member!(user1)
    vote = Vote.new(position: 'yes')
    vote.motion = @motion
    vote.user = user1
    vote.save
    @motion.blocked?.should == false
  end

  it "it can be blocked" do
    @motion = create(:motion)
    user1 = build(:user)
    user1.save
    @motion.group.add_member!(user1)
    vote = Vote.new(position: 'block')
    vote.motion = @motion
    vote.user = user1
    vote.save
    @motion.blocked?.should == true
  end

  it "can have a close date" do
    @motion = create(:motion)
    @motion.close_date = '2012-12-12'
    @motion.close_date.should == Date.parse('2012-12-12')
    @motion.should be_valid
  end

  it "can have a discussion link" do
    @motion = create(:motion)
    @motion.discussion_url = "http://our-discussion.com"
    @motion.should be_valid
  end

  it "can have a discussion" do
    @motion = create(:motion)
    @motion.save
    @motion.discussion.should_not be_nil
  end

  it "cannot have an outcome if voting open" do
    @motion = create(:motion)
    @motion.outcome.blank?.should == true
    @motion.set_outcome!("blah blah")
    @motion.save
    @motion.outcome.blank?.should == true
  end

  context "moving motion to new group" do
    before do
      @new_group = create(:group)
      @motion = create(:motion)
      @motion.move_to_group @new_group
    end

    it "changes motion group_id to new group" do
      @motion.group.should == @new_group
    end

    it "changes motion discussion_id to new group" do
      @motion.discussion.group.should == @new_group
    end
  end

  context "destroying a motion" do
    before do
      @discussion = create(:discussion)
      @motion = create(:motion, discussion: @discussion)
      @vote = Vote.create(position: "no", motion: @motion, user: @motion.author)
      @comment = @motion.discussion.add_comment(@motion.author, "hello")
      @motion.destroy
    end

    it "deletes associated votes" do
      Vote.first.should == nil
    end
  end

  context "closed motion" do
    before :each do
      @user1 = create(:user)
      @user2 = create(:user)
      @user3 = create(:user)
      @discussion = create(:discussion)
      @motion = create(:motion, discussion: @discussion)
      @motion.group.add_member!(@user2)
      @motion.group.add_member!(@user3)
      vote1 = create(:vote, :position => 'yes', :user => @user1, :motion => @motion)
      vote2 = create(:vote, :position => 'no', :user => @user2, :motion => @motion)
      @updated_at = @motion.updated_at
      @motion.close!
    end

    it "stores users who did not vote" do
      not_voted_ids = DidNotVote.all.collect {|u| u.user.id}
      not_voted_ids.should include(@user3.id)
    end

    it "users_who_did_not_vote returns users who did not vote" do
      @motion.users_who_did_not_vote.should include(@user3)
    end

    it "users_who_did_not_vote should not return users who did  vote" do
      @motion.users_who_did_not_vote.should_not include(@user1)
      @motion.users_who_did_not_vote.should_not include(@user2)
    end

    it "can have an outcome" do
      outcome = "Test Outcome"
      @motion.set_outcome!(outcome)
      @motion.save
      @motion.outcome.should == outcome
    end
  end

  describe "#no_vote_count" do
    let(:motion) { create :motion }

    it "returns the number of members who did not vote" do
      user = create :user
      motion.group.add_member! user
      create :vote, :motion => motion, :position => "yes", :user => user
      motion.no_vote_count.should == motion.group_users.count - 1
    end

    it "still works if the same user votes multiple times" do
      user = create :user
      motion.group.add_member! user
      create :vote, :motion => motion, :position => "yes", :user => user
      create :vote, :motion => motion, :position => "no", :user => user
      motion.no_vote_count.should == motion.group_users.count - 1
    end

    context "for a closed motion" do
      before { motion.close! }

      it "returns the number of members who did not vote" do
        motion.should be_closed
        motion.stub(:did_not_votes).and_return(stub :count => 99)
        motion.no_vote_count.should == 99
      end
    end
  end

  describe "#users_who_did_not_vote" do
    it "returns users who did not vote" do
      @user1 = create :user
      @group = create :group, :creator => @user1
      @discussion = create(:discussion, group: @group, author: @user1)
      @motion1 = create(:motion, name: "hi",
                                author: @user1,
                                discussion: @discussion,
                                phase: "voting")
      @motion1.author = @user1
      @motion1.save!
      @motion1.users_who_did_not_vote.should include(@user1)
    end
  end

  describe "number_of_votes_since_last_looked(user)" do
    before do
      @user = build(:user)
      @motion = create(:motion)
    end
    context "the user is a member of the motions group" do
      it "returns the total number of votes if the user has not seen the motion" do
        @motion.stub(:last_looked_at_by).with(@user).and_return(nil)
        @motion.stub_chain(:unique_votes, :count).and_return(4)

        @motion.number_of_votes_since_last_looked(@user).should == 4
      end
      it "returns the number of votes since the user last looked at the motion" do
        last_viewed_at = Time.now
        @user.stub(:is_group_member?).with(@motion.group).and_return(true)
        @motion.stub(:last_looked_at_by).with(@user).and_return(last_viewed_at)
        @motion.stub(:number_of_votes_since).with(last_viewed_at).and_return(3)

        @motion.number_of_votes_since_last_looked(@user).should == 3
      end
    end
    context "the user is not a member of the group" do
      it "returns the total number of votes" do
        @motion.stub(:last_looked_at_by).with(@user).and_return(nil)
        @motion.stub_chain(:unique_votes, :count).and_return(4)

        @motion.number_of_votes_since_last_looked(nil).should == 4
      end
    end
  end

  describe "last_looked_at_by(user)" do
    it "returns the date when the user last looked at the motion" do
      user = create :user
      motion = create :motion
      motion.stub(:read_log_for).and_return stub :motion_last_viewed_at => 123

      motion.last_looked_at_by(user).should == 123
    end

    it "returns nil if no read log exists" do
      user = create :user
      motion = create :motion
      motion.stub(:read_log_for).and_return nil

      motion.last_looked_at_by(user).should == nil
    end
  end

  describe "number_of_votes_since(time)" do
    it "returns the number of votes since time" do
      last_viewed_at = Time.now
      motion = create(:motion)
      motion.votes.stub_chain(:where, :count).and_return(4)

      motion.number_of_votes_since(last_viewed_at).should == 4
    end
  end

  describe "percent_voted" do
    before do
      @motion = create(:motion)
    end
    it "returns the pecentage of users that have voted" do
      @motion.stub(:no_vote_count).and_return(10)
      @motion.stub(:group_count).and_return(20)
      @motion.percent_voted.should == 50
    end
  end

  context do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      @motion = create(:motion, author: user1)
      @motion1 = create(:motion, author: user1)
    end

    describe "that_user_has_voted_on" do
      it "returns motions that the user has voted" do
        @motion.vote!(user1, 'yes', 'i agree!')
        Motion.that_user_has_voted_on(user1).should include(@motion)
      end
      it "does not return motions that the user has not voted on (even if another user has)" do
        @motion.group.add_member! user2
        @motion.vote!(user2, 'yes', 'i agree!')
        Motion.that_user_has_voted_on(user1).should_not include(@motion)
      end
    end
  end

  describe "vote!" do
    before do
      @motion = create(:motion)
      @vote = @motion.vote!(@motion.author, 'yes', 'i agree!')
    end
    it "returns a vote object" do
      @vote.is_a?(Vote).should be_true
    end
    it "assigns vote to the motion" do
      @motion.votes.should include(@vote)
    end
    it "assigns given position to vote" do
      @vote.position.should == 'yes'
    end
    it "assigns given statement to vote" do
      @vote.statement.should == "i agree!"
    end
    it "works if no statement given" do
      @vote = @motion.vote!(@motion.author, 'yes')
      @vote.should_not be_nil
    end
  end
end
