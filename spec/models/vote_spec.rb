require 'spec_helper'

describe Vote do
  before :each do
    @user = User.make
    @user.save
    @motion = create_motion
    @motion.group.add_member!(@user)
  end

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
    vote = Vote.make(position: 'bad')
    vote.valid?
    vote.should have(1).errors_on(:position)
  end

  it 'motion should only accept votes from users who belong to motion.group' do
    user2 = User.make
    user2.save
    vote = Vote.new(position: 'block', motion: @motion, user: user2)
    vote.should_not be_valid
  end

  it "motion should only accept votes during the motion's voting phase" do
    @motion.close_voting!
    vote = Vote.create(user: @user, motion: @motion, position: "yes")
    vote.errors.messages[:position].first.should match(
      /can only be modified while the motion is open/)
  end

  it 'sends notification email to author if block is issued' do
    MotionMailer.should_receive(:motion_blocked).with(kind_of(Vote))
      .and_return(stub(deliver: true))
    vote = Vote.new(position: 'block', motion: @motion, user: @user)
    vote.statement = "I'm blocking this motion"
    vote.save
  end

  it 'can have a statement' do
    vote = Vote.new(position: 'yes', motion: @motion,
                    user: @user)
    vote.statement = "This is what I think about the motion"
    vote.should be_valid
  end

  it 'cannot have a statement over 250 chars' do
    vote = Vote.new(position: 'yes', motion: create_motion, user: @user)
    vote.statement = "a"*251
    vote.should_not be_valid
  end

  it 'should not accept multiple votes on the same motion by the same user' do
    vote = Vote.new(position: 'yes', motion: @motion, user: @user)
    vote.save!
    vote1 = Vote.new(position: 'yes', motion: @motion, user: @user)
    vote1.should_not be_valid
  end
end
