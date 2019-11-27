require 'rails_helper'

describe PollSearch do
  let(:user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let!(:closed_long_ago)  { create :poll, closed_at: 1.month.ago, closing_at: 1.month.ago,      author: user }
  let!(:closed_soon)      { create :poll, closed_at: 1.day.ago,   closing_at: 1.day.ago,        author: user }
  let!(:closing_soon)     { create :poll, closed_at: nil,         closing_at: 1.day.from_now,   author: user }
  let!(:closing_far_away) { create :poll, closed_at: nil,         closing_at: 1.month.from_now, author: user }
  let(:search) { PollSearch.new(user) }
  let(:authored) { create :poll, author: user }
  let(:stance) { create :stance, participant: user }
  let(:participated) { create :poll, stances: [stance] }
  let(:in_a_discussion) { create :poll, discussion: discussion }
  let(:in_a_group) { create :poll, group: group }
  let(:rando) { create :poll }

  it 'sorts by closing at first' do
    expect(search.perform.map(&:id)).to eq [
      closing_soon.id,
      closing_far_away.id,
      closed_soon.id,
      closed_long_ago.id
    ]
  end

  describe 'perform' do
    before do
      group.add_member! user
      authored
      participated
      in_a_discussion
      in_a_group
      rando
    end

    it 'finds polls the user knows about' do
      results = search.perform
      expect(results).to include authored
      # expect(results).to include participated
      expect(results).to include in_a_discussion
      expect(results).to include in_a_group
      expect(results).to_not include rando
    end
  end
end
