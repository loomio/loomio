require 'rails_helper'

describe Motion do
  let(:discussion) { create :discussion }

  describe "#unique_votes" do
    it "returns only the most recent votes of a user for a motion" do
      user = FactoryGirl.create :user
      motion = create :motion, discussion: discussion
      discussion.group.add_member! user
      vote1 = Vote.create(motion_id: motion.id, user_id: user.id, position: "no")
      vote2 = Vote.create(motion_id: motion.id, user_id: user.id, position: "yes")

      expect(motion.votes.count).to eq 2
      expect(motion.unique_votes.count).to eq 1
      expect(motion.unique_votes.first).to eq vote2
    end
  end

  describe "#voting?" do
    it "returns true if motion is open" do
      @motion = create :motion, discussion: discussion
      @motion.voting?.should be true
      @motion.closed?.should be false
    end
  end

  describe "#closed?" do
    it "returns true if motion is open" do
      @motion = create(:motion, closed_at: 2.days.ago, discussion: discussion)
      @motion.closed?.should be true
      @motion.voting?.should be false
    end
  end

  describe "#user_has_voted?(user)" do
    it "returns true if the given user has voted on motion" do
      @user = create(:user)
      @motion = create(:motion, :author => @user, discussion: discussion)
      @vote = build(:vote,:position => "yes", motion: @motion)
      @vote.user = @user
      @vote.motion = @motion
      @vote.save!
      expect(@motion.user_has_voted?(@user)).to be true
    end
  end

  describe "#search(query)" do
    before { @user = create(:user) }
    it "returns user's motions that match the query string" do
      motion = create(:motion, name: "jam toast", author: @user, discussion: discussion)
      expect(@user.motions.search("jam")).to eq [motion]
    end
    it "does not return discussions that don't belong to the user" do
      motion = create(:motion, name: "sandwich crumbs", discussion: discussion)
      @user.motions.search("sandwich").should_not == [motion]
    end
  end

  describe "#members_not_voted_count" do
    let(:motion) { create :motion, discussion: discussion }

    it "returns the number of members who did not vote" do
      user = create :user
      motion.group.add_member! user
      create :vote, :motion => motion, :position => "yes", :user => user
      motion.reload
      expect(motion.members_not_voted_count).to eq motion.group_members.count - 1
    end

    it "still works if the same user votes multiple times" do
      user = create :user
      motion.group.add_member! user
      vote1 = create :vote, :motion => motion, :position => "yes", :user => user
      vote2 = create :vote, :motion => motion, :position => "no", :user => user
      expect(motion.members_not_voted_count).to eq motion.group_members.count - 1
    end

    context "for a closed motion" do
      before { MotionService.close(motion) }

      it "returns the number of members who did not vote" do
        motion.should be_closed
        motion.stub(:did_not_votes_count).and_return(99)
        expect(motion.members_not_voted_count).to eq 99
      end
    end
  end

  describe '#user_has_voted?' do
    before do
      @user = create :user
      @motion = create :motion, discussion: discussion
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
      it {should be true}
    end
    context 'user has not voted' do
      it {should be false}
    end
  end

  describe "percent_voted" do
    before do
      @motion = create(:motion, discussion: discussion)
    end
    it "returns the pecentage of users that have voted" do
      @motion.stub(:members_not_voted_count).and_return(10)
      @motion.stub(:group_size_when_voting).and_return(20)
      expect(@motion.percent_voted).to eq 50
    end
  end


  describe 'update_vote_counts!' do
    context 'there is 1 vote for each position' do
      let(:group){FactoryGirl.create :group}
      let(:discussion){create :discussion, group: group}
      let(:motion){FactoryGirl.create :motion, discussion: discussion}

      before do
        Vote::POSITIONS.each do |position|
          user = create(:user)
          group.add_member!(user)

          vote = Vote.new(position: position)
          vote.motion = motion
          vote.user = user
          vote.save!
          motion.reload
        end
      end

      context 'after updating the vote_counts' do
        it 'has counts of 1' do
          expect(motion.yes_votes_count).to eq 1
          expect(motion.no_votes_count).to eq 1
          expect(motion.abstain_votes_count).to eq 1
          expect(motion.block_votes_count).to eq 1
        end
      end
    end
  end
end
