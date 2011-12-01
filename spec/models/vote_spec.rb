require 'spec_helper'

describe Vote do
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
    @vote = Vote.make(position: 'bad')
    @vote.valid?
    @vote.should have(1).errors_on(:position)
  end 

  it 'can have a statement' do
    @vote = Vote.new(position: 'yes', motion: create_motion, user: User.make!)
    @vote.statement = "This is what I think about the motion"
    @vote.should be_valid
  end
  it 'cannot have a statement over 500 chars' do
    @vote = Vote.new(position: 'yes', motion: create_motion, user: User.make!)
    @vote.statement = "fooo"*500
    @vote.should_not be_valid
  end
end
