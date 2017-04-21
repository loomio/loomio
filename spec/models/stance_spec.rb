require 'rails_helper'
describe Stance do
  describe 'stance choice validation' do
    let(:poll) { create :poll }
    let(:proposal) { create :poll_proposal }
    let(:user) { create :user }

    it 'allows no stance choices for meetings / polls' do
      expect(Stance.new(poll: poll, participant: user)).to be_valid
    end

    it 'requires a stance choice for proposals' do
      expect(Stance.new(poll: proposal, participant: user)).to_not be_valid
    end
  end

  describe 'choice shorthand' do
    let(:poll) { Poll.create!(poll_type: 'poll', title: 'which pet?', poll_option_names: %w[dog cat], closing_at: 1.day.from_now, author: author)}
    let(:author) { FactoryGirl.create(:user) }

    it "string" do
      stance = Stance.create(poll: poll, participant: author, choice: 'dog')
      poll.update_stance_data
      expect(poll.stance_data).to eq({'dog' => 1, 'cat' => 0})
    end

    it "array" do
      stance = Stance.create(poll: poll, participant: author, choice: ['dog', 'cat'])
      poll.update_stance_data
      expect(poll.stance_data).to eq({'dog' => 1, 'cat' => 1})
    end

    # TODO: when we have poll types which accept alternate scores, update this test to test that.
    it "map" do
      stance = Stance.create(poll: poll, participant: author, choice: {'dog' => 1, 'cat' => 1})
      poll.update_stance_data
      expect(poll.stance_data).to eq({'dog' => 1, 'cat' => 1})
    end

  end
end
