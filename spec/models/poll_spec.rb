require 'rails_helper'

describe Poll do
  let(:poll_option) { create :poll_option, name: "agree" }
  let(:poll) { build :poll, poll_options: [poll_option] }

  it 'validates correctly if no poll option changes have been made' do
    expect(poll.valid?).to eq true
  end

  it 'does not allow changing poll options if the template does not allow' do
    poll.poll_options.build
    expect(poll.valid?).to eq false
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
    let(:community) { poll.communities.create(community_type: :public) }

    it 'creates a public community if true' do
      expect { poll.update(anyone_can_participate: true) }.to change { poll.communities.count }.by(1)
    end

    it 'removes the public community if it exists' do
      community
      poll.update(anyone_can_participate: true)
      expect { poll.update(anyone_can_participate: false) }.to change { poll.communities.count }.by(-1)
    end

    it 'does nothing if public community is already present' do
      community
      expect { poll.update(anyone_can_participate: true) }.to_not change { poll.communities.count }
    end

    it 'does nothing if public community doesnt exist' do
      expect { poll.update(anyone_can_participate: false) }.to_not change { poll.communities.count }
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
end
