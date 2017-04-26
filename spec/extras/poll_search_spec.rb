require 'rails_helper'

describe PollSearch do
  let(:user) { create :user }
  let!(:closed_long_ago)  { create :poll, closed_at: 1.month.ago, closing_at: 1.month.ago,      author: user }
  let!(:closed_soon)      { create :poll, closed_at: 1.day.ago,   closing_at: 1.day.ago,        author: user }
  let!(:closing_soon)     { create :poll, closed_at: nil,         closing_at: 1.day.from_now,   author: user }
  let!(:closing_far_away) { create :poll, closed_at: nil,         closing_at: 1.month.from_now, author: user }
  let(:search) { PollSearch.new(user) }

  it 'sorts by closing at first' do
    expect(search.perform.map(&:id)).to eq [
      closing_soon.id,
      closing_far_away.id,
      closed_soon.id,
      closed_long_ago.id
    ]
  end
end
