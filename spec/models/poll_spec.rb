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

    it 'is not a new version if anyone_can_participate is changed' do
      poll.anyone_can_participate = false
      expect(poll.is_new_version?).to eq false
    end
  end

  describe 'members' do
    let(:poll) { create :poll, group: create(:formal_group) }
    let(:user) { create :user }

    it 'includes guests' do
      expect {
        Stance.create(poll: poll, participant: user)
      }.to change { poll.members.count }.by(1)
    end

    it 'includes members of the formal group' do
      expect {
        poll.group.add_member! user
      }.to change { poll.members.count }.by(1)
    end
  end

  describe 'voters and participants and undecided' do
    let(:poll) { create :poll, group: create(:formal_group) }
    let(:user) { create :user }

    it 'increments voters when a vote is created' do
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.voters.count }.by(1)
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.participants.count }.by(0)
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.undecided.count }.by(1)
    end

    it 'increments participants when a vote is cast' do
      expect { create(:stance, poll: poll, choice: poll.poll_option_names.first, participant: user) }.to change { poll.voters.count }.by(1)
      expect { create(:stance, poll: poll, choice: poll.poll_option_names.first, participant: user) }.to change { poll.participants.count }.by(1)
      expect { create(:stance, poll: poll, choice: poll.poll_option_names.first, participant: user) }.to change { poll.undecided.count }.by(0)
    end
  end

  describe 'time_zone' do
    let(:poll) { create :poll, group: create(:formal_group), author: user }
    let(:user) { create :user, time_zone: "Asia/Seoul" }

    it 'defaults to the authors time zone' do
      expect(poll.time_zone).to eq user.time_zone
    end
  end
end
