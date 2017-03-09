require 'rails_helper'

describe StanceChoice do
  let(:poll) { create :poll }
  let(:choice) { build :stance_choice, poll: poll, score: 1 }

  it 'allows scores == 1' do
    expect(choice).to be_valid
  end

  it 'allows scores > 1 if poll allows it' do
    poll.stub(:has_variable_score).and_return(true)
    choice.score = 4
    expect(choice).to be_valid
  end

  it 'does not allow scores > 1 if poll disallows it' do
    choice.score = 4
    expect(choice).to_not be_valid
  end

  # it 'does not allow scores < 1' do
  #   poll.stub(:has_variable_score).and_return(true)
  #   choice.score = 0
  #   expect(choice).to_not be_valid
  # end
end
