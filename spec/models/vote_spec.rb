require 'spec_helper'

describe Vote do
  let(:user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:motion) { create(:motion, discussion: discussion) }

  it { Vote::POSITION_VERBS['yes'].should == 'agreed' }
  it { Vote::POSITION_VERBS['abstain'].should == 'abstained' }
  it { Vote::POSITION_VERBS['no'].should == 'disagreed' }
  it { Vote::POSITION_VERBS['block'].should == 'blocked' }

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

  it 'should only accept valid position values' do
    vote = build(:vote, position: 'bad')
    vote.valid?
    vote.should have(1).errors_on(:position)
  end

  it 'motion should only accept votes from users who belong to motion.group' do
    user2 = build(:user)
    user2.save
    vote = Vote.new(position: 'block')
    vote.motion = motion
    vote.user = user2
    vote.should_not be_valid
  end

  it "motion should only accept votes during the motion's voting phase" do
    motion.close_voting!
    vote = Vote.new(position: "yes")
    vote.motion = motion
    vote.user = user
    vote.save
    vote.errors.messages[:position].first.should match(/can only be modified while the motion is open/)
  end

  it 'sends notification email to author if block is issued' do
    MotionMailer.should_receive(:motion_blocked).with(kind_of(Vote))
      .and_return(stub(deliver: true))
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
    vote.motion = create(:motion)
    vote.user = user
    vote.statement = "a"*251
    vote.should_not be_valid
  end

  it 'should update motion_last_vote_at when new vote is created' do
    vote = Vote.new(position: "yes")
    vote.motion = motion
    vote.user = user
    vote_time = stub "time"
    motion.stub(:latest_vote_time).and_return(vote_time)
    motion.should_receive(:last_vote_at=).with(vote_time)
    motion.should_receive(:save!)
    vote.save!
  end

  it 'should update motion_last_vote_at when vote is changed' do
    pending "This is currently happening in the VotesController#update. But it should be moved into the model"
    vote = Vote.new(position: 'yes')
    vote.motion = motion
    vote.user = user
    vote.save!
    vote.position = 'no'
    motion.stub(:latest_vote_time).and_return(vote_time)
    motion.should_receive(:last_vote_at=).with(vote_time)
    motion.should_receive(:save!)
    vote.save!
  end

  describe 'other_group_members' do
    it 'returns members in the group' do
      pending
      vote.other_group_members.should include bill
    end

    it 'does not return the voter' do
      pending
      vote.other_group_members.should_not include sam
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
end
