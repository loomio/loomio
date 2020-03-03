require 'rails_helper'

describe Poll do
  let(:poll_option) { create :poll_option, name: "agree" }
  let(:poll) { build :poll, poll_options: [poll_option] }
  let(:ranked_choice) { build :poll_ranked_choice }

  it 'validates correctly if no poll option changes have been made' do
    expect(poll.valid?).to eq true
  end

  it 'does not allow changing poll options if the template does not allow' do
    poll.poll_options.build
    expect(poll.valid?).to eq false
  end

  it 'does not allow higher minimum stance choices than number of poll options' do
    ranked_choice.minimum_stance_choices = ranked_choice.poll_options.length + 1
    expect(ranked_choice).to_not be_valid
  end

  it 'allows closing dates in the future' do
    poll.closing_at = 1.day.from_now
    expect(poll).to be_valid
  end

  it 'disallows closing dates in the past' do
    poll.closing_at = 1.day.ago
    expect(poll).to_not be_valid
  end

  it 'allows past closing dates if it is closed' do
    poll.closed_at = 1.day.ago
    poll.closing_at = 1.day.ago
    expect(poll).to be_valid
  end

  it 'assigns poll options' do
    option_poll = create :poll, poll_option_names: ['A', 'C', 'B']
    expect(option_poll.poll_options.map(&:name)).to eq ['A', 'C', 'B']
  end

  describe 'ordered_poll_options' do
    let(:poll) { create :poll }
    let(:meeting) { create :poll_meeting }

    it 'orders by priority when non-meeting poll' do
      poll.update(poll_option_names: [
        'Orange',
        'Apple',
        'Pineapple'
      ])
      expect(poll.ordered_poll_options.first.name).to eq 'Orange'
    end

    it 'orders by name when meeting poll' do
      meeting.update(poll_option_names: [
        '01-01-2018',
        '01-01-2017',
        '01-01-2016',
      ])
      expect(meeting.ordered_poll_options.first.name).to eq '01-01-2016'
    end
  end

  describe 'is_new_version?' do
    before { poll.save }

    it 'is a new version if title is changed' do
      poll.title = "new title"
      expect(poll.is_new_version?).to eq true
    end

    it 'is a new version if new poll option is added' do
      poll.poll_option_names = "new_option"
      expect(poll.is_new_version?).to eq true
    end

    it 'is not a new version if voteable_by is changed' do
      poll.voteable_by = 'invited'
      expect(poll.is_new_version?).to eq false
    end
  end

  describe 'permissions' do
    let(:parent_group) { create :group }
    let(:group)        { create :group, parent: parent_group }
    let(:poll)         { create :poll, group: group, author: poll_author }
    let(:user)         { create :user }

    let(:poll_author)       { create :user }
    let(:public_user)       { create :user }
    let(:parent_group_user) { create :user }
    let(:group_user)        { create :user }
    let(:invited_user)      { create :user }

    before do
      parent_group.add_member! parent_group_user
      group.add_member! group_user
      poll.stances.create!(user: invited_user)
    end

    describe 'visible_by' do
      it 'public' do
        poll.visible_by = 'public'
        expect(public_user.ability.can?(:show, poll)).to be true
        expect(parent_group_user.ability.can?(:show, poll)).to be true
        expect(group_user.ability.can?(:show, poll)).to be true
        expect(invited_user.ability.can?(:show, poll)).to be true
        expect(poll_author.ability.can?(:show, poll)).to be true
      end

      it 'parent_group' do
        poll.visible_by = 'parent_group'
        expect(public_user.ability.can?(:show, poll)).to be false
        expect(parent_group_user.ability.can?(:show, poll)).to be true
        expect(group_user.ability.can?(:show, poll)).to be true
        expect(invited_user.ability.can?(:show, poll)).to be true
      end

      it 'group' do
        poll.visible_by = 'group'
        expect(public_user.ability.can?(:show, poll)).to be false
        expect(parent_group_user.ability.can?(:show, poll)).to be false
        expect(group_user.ability.can?(:show, poll)).to be true
        expect(invited_user.ability.can?(:show, poll)).to be true
      end

      it 'invited' do
        # only those people specifically invited to the poll
        poll.visible_by = 'invited'
        expect(public_user.ability.can?(:show, poll)).to be false
        expect(parent_group_user.ability.can?(:show, poll)).to be false
        expect(group_user.ability.can?(:show, poll)).to be false
        expect(invited_user.ability.can?(:show, poll)).to be true
      end
    end

    describe 'voteable_by' do
      it 'public' do
        poll.voteable_by = 'public'
        expect(public_user.ability.can?(:vote_in, poll)).to be true
        expect(parent_group_user.ability.can?(:vote_in, poll)).to be true
        expect(group_user.ability.can?(:vote_in, poll)).to be true
        expect(invited_user.ability.can?(:vote_in, poll)).to be true
      end

      it 'parent_group' do
        poll.voteable_by = 'parent_group'
        expect(public_user.ability.can?(:vote_in, poll)).to be false
        expect(parent_group_user.ability.can?(:vote_in, poll)).to be true
        expect(group_user.ability.can?(:vote_in, poll)).to be true
        expect(invited_user.ability.can?(:vote_in, poll)).to be true
      end

      it 'group' do
        poll.voteable_by = 'group'
        expect(public_user.ability.can?(:vote_in, poll)).to be false
        expect(parent_group_user.ability.can?(:vote_in, poll)).to be false
        expect(group_user.ability.can?(:vote_in, poll)).to be true
        expect(invited_user.ability.can?(:vote_in, poll)).to be true
      end

      it 'invited' do
        poll.voteable_by = 'invited'
        expect(public_user.ability.can?(:vote_in, poll)).to be false
        expect(parent_group_user.ability.can?(:vote_in, poll)).to be false
        expect(group_user.ability.can?(:vote_in, poll)).to be false
        expect(invited_user.ability.can?(:vote_in, poll)).to be true
      end
    end
  end

  describe 'voters' do
    # a person who votes or has the right to vote at an election.

    context 'voteable_by' do
      it 'public' do
        # voters is just those people who have voted already
        expect(poll.voters.includes?(parent_group_user)).to be true
        expect(poll.voters.includes?(group_user)).to be true
        expect(poll.voters.includes?(invited_user)).to be true
      end

      it 'parent_group' do
        expect(poll.voters.includes?(parent_group_user)).to be true
        expect(poll.voters.includes?(group_user)).to be true
        expect(poll.voters.includes?(invited_user)).to be true
      end

      it 'group' do
        expect(poll.voters.includes?(parent_group_user)).to be false
        expect(poll.voters.includes?(group_user)).to be true
        expect(poll.voters.includes?(invited_user)).to be true
      end

      it 'invited' do
        expect(poll.voters.includes?(parent_group_user)).to be false
        expect(poll.voters.includes?(group_user)).to be false
        expect(poll.voters.includes?(invited_user)).to be true
      end
    end
  end

  describe 'undecided' do
    let!(:group) { create :group }
    let!(:poll) { create :poll, group: group, discussion: discussion }
    let!(:discussion) { create :discussion, group: group }
    let!(:user) { create :user }

    before do
      poll.update_undecided_count
    end

    context 'voteable_by' do
      it 'public' do
      end

      it 'parent_group' do
      end

      it 'group' do
      end

      it 'invited' do
      end
    end

    it 'includes guests' do
      expect {
        Stance.create(poll: poll, participant: create(:user))
      }.to change { poll.reload.undecided_count }.by(1)
    end

    it 'includes members of the formal group' do
      expect {
        poll.group.add_member! user
      }.to change { poll.reload.undecided_count }.by(1)
    end

    # it 'includes members of the discussion group' do
    #   expect {
    #     poll.discussion.guest_group.add_member! user
    #   }.to change { poll.reload.undecided_count }.by(1)
    # end

    it 'decrements when removing from the guest group' do
      membership = poll.guest_group.add_member! user
      expect { membership.destroy }.to change { poll.reload.undecided_count }.by(-1)
    end

    it 'decrements when removing from the discussion group' do
      membership = poll.discussion.guest_group.add_member! user
      expect { membership.destroy }.to change { poll.reload.undecided_count }.by(-1)
    end

    it 'decrements when removing from the formal group' do
      membership = poll.group.add_member! user
      expect { membership.destroy }.to change { poll.reload.undecided_count }.by(-1)
    end

    it 'decrements when a vote is created' do
      poll.group.add_member! user
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.reload.undecided_count }.by(-1)
    end
  end

  describe 'participants' do
    let(:poll) { create :poll, group: create(:group) }
    let(:user) { create :user }

    it 'increments when a vote is created' do
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.participants.count }.by(1)
    end
  end

  describe 'time_zone' do
    let(:poll) { create :poll, group: create(:group), author: user }
    let(:user) { create :user, time_zone: "Asia/Seoul" }

    it 'defaults to the authors time zone' do
      expect(poll.time_zone).to eq user.time_zone
    end
  end
end
