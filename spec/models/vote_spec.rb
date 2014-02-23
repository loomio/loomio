require 'spec_helper'

describe Vote do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create_discussion group: group, author: user }
  let(:motion) { create(:motion, discussion: discussion) }

  it { should have_many(:events).dependent(:destroy) }

  context 'a new vote' do
    subject do
      @vote = Vote.new
      @vote.valid?
      @vote
    end

    it {should have(1).errors_on(:motion)}
    it {should have(1).errors_on(:user)}
    it {should have(2).errors_on(:position)}
  end

  context 'user votes' do
    let(:vote) { Vote.create(user: user, motion: motion, position: "no") }
    subject { vote }

    its(:age) { should == 0 }

    context 'user changes their position' do
      let(:vote2) { Vote.create(user: user, motion: motion, position: "yes") }
      before do
        vote
        vote2
      end

      subject { vote2 }
      its(:age) { should == 0 }

      it "should age the first vote" do
        vote.reload
        vote.age.should == 1
      end

      it 'the second vote should associate the first as the previous' do
        vote2.previous_vote_id.should == vote.id
      end
    end
  end

  it 'should only accept valid position values' do
    vote = build(:vote, position: 'bad', motion: motion)
    vote.valid?
    vote.should have(1).errors_on(:position)
  end

  it 'sends notification email to author if block is issued' do
    MotionMailer.should_receive(:motion_blocked).with(kind_of(Vote))
      .and_return(double(deliver: true))
    vote = Vote.new(position: 'block', statement: "I'm blocking this motion")
    vote.motion = motion
    vote.user = user
    vote.save
  end

  it 'can have a statement' do
    vote = Vote.new(position: "yes", statement: "This is what I think about the motion")
    vote.motion = motion
    vote.user = user
    vote.should be_valid
  end

  it 'cannot have a statement over 250 chars' do
    vote = Vote.new(position: 'yes')
    vote.motion = create(:motion, discussion: discussion)
    vote.user = user
    vote.statement = "a"*251
    vote.should_not be_valid
  end

  it 'should update motion_last_vote_at when new vote is created' do
    vote = Vote.new(position: "yes")
    vote.motion = motion
    vote.user = user
    vote_time = "time"
    motion.stub(:latest_vote_time).and_return(vote_time)
    motion.should_receive(:last_vote_at=).with(vote_time)
    vote.save!
  end

  describe 'other_group_members' do
    before do
      @user1 = create :user
      group.add_member!(@user1)
      @vote = create :vote, user: user, motion: motion
    end

    it 'returns members in the group' do
      @vote.other_group_members.should include @user1
    end

    it 'does not return the voter' do
      @vote.other_group_members.should_not include user
    end
  end

  describe "previous_vote" do
    it "gets position from previous vote on same motion by same user
        (if any)" do
      vote = Vote.new(position: 'abstain')
      vote.motion = motion
      vote.user = user
      vote.save!

      vote2 = Vote.new(position: 'yes')
      vote2.motion = motion
      vote2.user = user
      vote2.save!

      vote2.previous_vote.id.should == vote.id
    end
  end
  context "when a vote is created" do
    it "fires a 'new_vote' event" do
      motion = create :motion, discussion: discussion
      Events::NewVote.should_receive(:publish!)
      vote = create :vote, :motion => motion, :position => "yes"
    end
  end
  context "when a vote is blocked" do
    it "fires a 'motion_blocked' event" do
      motion = create :motion, discussion: discussion
      Events::MotionBlocked.should_receive(:publish!)
      vote = create :vote, :motion => motion, :position => "block"
    end
  end
end
