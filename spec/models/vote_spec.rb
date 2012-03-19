require 'spec_helper'

describe Vote do
  let (:user) { User.make! }

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

  it 'should only accept votes from users who belong to the group containing the motion'

  it "should only accept votes during the motion's voting phase"

  it 'sends notification email to author if block is issued' do
    motion = create_motion(author: user)
    vote = Vote.new(position: 'block', motion: motion, user: User.make!)
    vote.statement = "I'm blocking this motion"
    vote.save
    MotionMailer.motion_blocked(vote)
  end

  it 'can have a statement' do
    vote = Vote.new(position: 'yes', motion: create_motion, user: User.make!)
    vote.statement = "This is what I think about the motion"
    vote.should be_valid
  end

  it 'cannot have a statement over 250 chars' do
    vote = Vote.new(position: 'yes', motion: create_motion, user: User.make!)
    vote.statement = "fooo"*250
    vote.should_not be_valid
  end

  it 'should not accept multiple votes on the same motion by the same user' do
    motion = create_motion
    vote = Vote.new(position: 'yes', motion: motion, user: user)
    vote.save!
    vote1 = Vote.new(position: 'yes', motion: motion, user: user)
    vote1.should_not be_valid
  end
end
