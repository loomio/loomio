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
      @comment = @motion.discussion.add_comment(@motion.author, "hello", uses_markdown: false)
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
      MotionService.close(@motion)
    end

    it "stores users who did not vote" do
      not_voted_ids = DidNotVote.all.collect {|u| u.user.id}
      not_voted_ids.should include(@user3.id)
    end
  end

  describe "#members_not_voted_count" do
    let(:motion) { create :motion }

    it "returns the number of members who did not vote" do
      user = create :user
      motion.group.add_member! user
      create :vote, :motion => motion, :position => "yes", :user => user
      motion.reload
      motion.members_not_voted_count.should == motion.group_users.count - 1
    end

    it "still works if the same user votes multiple times" do
      user = create :user
      motion.group.add_member! user
      create :vote, :motion => motion, :position => "yes", :user => user
      create :vote, :motion => motion, :position => "no", :user => user
      motion.reload
      motion.members_not_voted_count.should == motion.group_users.count - 1
    end

    context "for a closed motion" do
      before { MotionService.close(motion) }

      it "returns the number of members who did not vote" do
        motion.should be_closed
        motion.stub(:did_not_votes_count).and_return(99)
        motion.members_not_voted_count.should == 99
      end
    end
  end

  describe '#user_has_voted?' do
    before do
      @user = create :user
      @motion = create :motion
      @motion.group.add_member!(@user)
    end
    subject {@motion.user_has_voted?(@user)}
    context 'user has voted' do
      before do
        @vote = Vote.new
        @vote.position = 'yes'
        @vote.motion = @motion
        @vote.user = @user
        @vote.save!
        @motion.reload
      end
      it {should be_true}
    end
    context 'user has not voted' do
      it {should be_false}
    end
  end

  describe "percent_voted" do
    before do
      @motion = create(:motion)
    end
    it "returns the pecentage of users that have voted" do
      @motion.stub(:members_not_voted_count).and_return(10)
      @motion.stub(:group_size_when_voting).and_return(20)
      @motion.percent_voted.should == 50
    end
  end


  describe 'update_vote_counts!' do
    context 'there is 1 vote for each position' do
      let(:group){FactoryGirl.create :group}
      let(:discussion){create_discussion group: group}
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
