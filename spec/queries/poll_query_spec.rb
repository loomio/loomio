require 'rails_helper'

describe PollQuery do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let!(:closed_long_ago)  { create :poll, closed_at: 1.month.ago, closing_at: 1.month.ago,      author: user }
  let!(:closed_soon)      { create :poll, closed_at: 1.day.ago,   closing_at: 1.day.ago,        author: user }
  let!(:closing_soon)     { create :poll, closed_at: nil,         closing_at: 1.day.from_now,   author: user }
  let!(:closing_far_away) { create :poll, closed_at: nil,         closing_at: 1.month.from_now, author: user }
  let(:authored) { create :poll, author: user }
  let(:stance) { create :stance, participant: user }
  let(:participated) { create :poll, stances: [stance] }
  let(:in_a_discussion) { create :poll, discussion: discussion }
  let(:in_a_group) { create :poll, group: group }
  let(:rando) { create :poll }
  let(:rando_in_group) { create :poll, group: create(:group) }

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
      results = PollQuery.visible_to(user: user)
      # expect(results).to include authored
      expect(results).to include participated
      expect(results).to include in_a_discussion
      expect(results).to include in_a_group
      expect(results).to_not include rando_in_group
      expect(results).to_not include rando
    end
  end

  describe "base_guest_audience_query" do
    let!(:reader_user) { create(:user, name: 'reader user') }

    describe "reader user" do
      let!(:discussion) { create(:discussion) }
      let!(:poll) { create(:poll, discussion: discussion) }

      before do
        discussion.add_guest! reader_user, reader_user
      end

      it 'returns users from the discussion' do
        expect(poll.base_guest_audience_query.exists?(reader_user.id)).to be true
      end
    end

    describe "member user" do
      let!(:member_user) { create(:user, name: 'member user') }
      let!(:group) { create(:group) }
      let!(:poll) { create(:poll, group: group) }

      before do
        group.add_member! member_user
      end

      it 'returns users from the group' do
        expect(poll.base_guest_audience_query.exists?(member_user.id)).to be true
      end
    end

    describe "stance user" do
      let!(:stance_user) { create(:user, name: 'stance user') }
      let!(:poll) { create(:poll) }

      before do
        poll.add_guest! stance_user, stance_user
      end

      it 'returns users from the poll' do
        expect(poll.base_guest_audience_query.exists?(stance_user.id)).to be true
      end
    end
  end
end
