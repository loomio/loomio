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
    @vote = Vote.make(:position => 'bad')
    @vote.valid?
    @vote.should have(1).errors_on(:position)
  end 
end
