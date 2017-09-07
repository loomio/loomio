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

  describe 'anyone_can_participate=' do
    before { poll.save }

    it 'changes guest group membership_granted_upon to request' do
      poll.update(anyone_can_participate: true)
      expect(poll.guest_group.reload.membership_granted_upon).to eq 'request'
    end

    it 'changes guest group membership_granted_upon to approval' do
      poll.update(anyone_can_participate: false)
      expect(poll.guest_group.reload.membership_granted_upon).to eq 'invitation'
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

    it 'includes members of the guest group' do
      expect {
        poll.guest_group.add_member! user
      }.to change { poll.members.count }.by(1)
    end

    it 'includes members of the formal group' do
      expect {
        poll.group.add_member! user
      }.to change { poll.members.count }.by(1)
    end

    it 'decrements when removing from the guest group' do
      membership = poll.guest_group.add_member! user
      expect { membership.destroy }.to change { poll.members.count }.by(-1)
    end

    it 'decrements when removing from the formal group' do
      membership = poll.group.add_member! user
      expect { membership.destroy }.to change { poll.members.count }.by(-1)
    end
  end

  describe 'undecided' do
    let(:poll) { create :poll, group: create(:formal_group) }
    let(:user) { create :user }

    it 'includes members of the guest group' do
      expect {
        poll.guest_group.add_member! user
      }.to change { poll.undecided.count }.by(1)
    end

    it 'includes members of the formal group' do
      expect {
        poll.group.add_member! user
      }.to change { poll.undecided.count }.by(1)
    end

    it 'decrements when removing from the guest group' do
      membership = poll.guest_group.add_member! user
      expect { membership.destroy }.to change { poll.undecided.count }.by(-1)
    end

    it 'decrements when removing from the formal group' do
      membership = poll.group.add_member! user
      expect { membership.destroy }.to change { poll.undecided.count }.by(-1)
    end

    it 'decrements when a vote is created' do
      poll.group.add_member! user
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.undecided.count }.by(-1)
    end
  end

  describe 'participants' do
    let(:poll) { create :poll, group: create(:formal_group) }
    let(:user) { create :user }

    it 'increments when a vote is created' do
      expect { create(:stance, poll: poll, participant: user) }.to change { poll.participants.count }.by(1)
    end
  end
end
