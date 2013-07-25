require 'spec_helper'

describe Motion do
  describe "#voting?" do
    it "returns true if motion is open" do
      @motion = create :motion
      @motion.voting?.should be_true
      @motion.closed?.should be_false
    end
  end

  describe "#closed?" do
    it "returns true if motion is open" do
      @motion = create(:motion, closed_at: 2.days.ago)
      @motion.closed?.should be_true
      @motion.voting?.should be_false
    end
  end

  it "assigns the close_at from close_at_* fields" do
    close_date = "23-05-2013"
    close_time = "15:00"
    time_zone = "Saskatchewan"
    motion = build(:motion, close_at_date: close_date, close_at_time: close_time, close_at_time_zone: time_zone)
    motion.save!
    motion.closing_at.in_time_zone("Saskatchewan").to_s.should == "2013-05-23 15:00:00 -0600"
  end

  describe "#user_has_voted?(user)" do
    it "returns true if the given user has voted on motion" do
      @user = create(:user)
      @motion = create(:motion, :author => @user)
      @vote = build(:vote,:position => "yes")
      @vote.user = @user
      @vote.motion = @motion
      @vote.save!
      @motion.user_has_voted?(@user).should == true
    end

    it "returns false if given nil" do
      @motion = create(:motion)
      @motion.user_has_voted?(nil).should == false
    end
  end

  describe "#search(query)" do
    before { @user = create(:user) }
    it "returns user's motions that match the query string" do
      motion = create(:motion, name: "jam toast", author: @user)
      @user.motions.search("jam").should == [motion]
    end
    it "does not return discussions that don't belong to the user" do
      motion = create(:motion, name: "sandwich crumbs")
      @user.motions.search("sandwich").should_not == [motion]
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
      motion = build(:motion)
      motion.should_receive(:fire_new_motion_event)
      motion.save!
    end
    it "adds motion closed activity if a motion is closed" do
      motion = create :motion, :discussion => @discussion
      Events::MotionClosed.should_receive(:publish!)
      motion.close!(@user)
    end
  end

  describe "#blocked?" do
    before do
      @motion = create(:motion)
      @user1 = build(:user)
      @user1.save
      @motion.group.add_member!(@user1)
    end
    it "it can remain un-blocked" do
      vote = Vote.new(position: 'yes')
      vote.motion = @motion
      vote.user = @user1
      vote.save
      @motion.blocked?.should == false
    end

    it "it can be blocked" do
      vote = Vote.new(position: 'block')
      vote.motion = @motion
      vote.user = @user1
      vote.save
      @motion.blocked?.should == true
    end
  end

  it "can have a discussion link" do
    @motion = create(:motion)
    @motion.discussion_url = "http://our-discussion.com"
    @motion.should be_valid
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
      @comment = @motion.discussion.add_comment(@motion.author, "hello", false)
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
    before do
      @user = create :user
      @motion = create :motion
    end
    it "returns the date when the user last looked at the motion" do
      @motion.stub(:read_log_for).and_return stub :motion_last_viewed_at => 123
      @motion.last_looked_at_by(@user).should == 123
    end
    it "returns nil if no read log exists" do
      @motion.stub(:read_log_for).and_return nil
      @motion.last_looked_at_by(@user).should == nil
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

  describe "that_user_has_voted_on" do
    before do
      @user1 = create :user
      @motion = create(:motion, author: @user1)
      @motion1 = create(:motion, author: @user1)
    end
    it "returns motions that the user has voted" do
      @motion.vote!(@user1, 'yes', 'i agree!')
      Motion.that_user_has_voted_on(@user1).should include(@motion)
    end
    it "does not return motions that the user has not voted on (even if another user has)" do
      @user2 = create :user
      @motion.group.add_member! @user2
      @motion.vote!(@user2, 'yes', 'i agree!')
      Motion.that_user_has_voted_on(@user1).should_not include(@motion)
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

  describe "#has_revisions?" do
    before do
      @motion = create(:motion)
    end
    it "returns true if there are no revisions" do
      @motion.has_revisions?.should be_false
    end
    it "returns false if there are revisions" do
      @motion.description = "Ch-ch-changes"
      @motion.save!
      @motion.has_revisions?.should be_true
    end
  end

  describe 'update_vote_counts!', focus: true do
    context 'there is 1 vote for each position' do
      let(:group){FactoryGirl.create :group}
      let(:discussion){FactoryGirl.create :discussion, group: group}
      let(:motion){FactoryGirl.create :motion, discussion: discussion}

      before do
        Vote::POSITIONS.each do |position|
          user = create(:user)
          group.add_member!(user)

          vote = Vote.new(position: position)
          vote.motion = motion
          vote.user = user
          vote.save!
        end
      end

      context 'after updating the vote_counts' do
        it 'has counts of 1' do
          motion.yes_votes_count.should == 1
          motion.no_votes_count.should == 1
          motion.abstain_votes_count.should == 1
          motion.block_votes_count.should == 1
        end
      end
    end
  end
end
