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

  describe 'poll_option_names=' do
    let(:option_poll) { create :poll, poll_option_names: ['A', 'C', 'B'] }
    it 'assigns poll options' do
      expect(option_poll.poll_options.map(&:name)).to eq ['A', 'C', 'B']
    end

    it 'sorts poll options for date polls' do
      option_poll.update(poll_type: :meeting)
      expect(option_poll.poll_options.map(&:name)).to eq ['A', 'B', 'C']
    end
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

  describe 'group_id=' do
    before { group.community; another_group.community; poll.save }
    let(:group) { create :group }
    let(:another_group) { create :group }

    it 'creates a group community if true' do
      expect { poll.update(group_id: group.id) }.to change { poll.communities.count }.by(1)
      expect(poll.communities).to include group.community
      expect(poll.reload.group_id).to eq group.id
    end

    it 'removes the group community if it exists' do
      poll.update(group_id: group.id)
      expect { poll.update(group_id: nil) }.to change { poll.communities.count }.by(-1)
      expect(poll.reload.group_id).to be_nil
    end

    it 'updates the existing group community if it exists' do
      poll.update(group_id: group.id)
      expect { poll.update(group_id: another_group.id) }.to_not change { poll.communities.count }
      expect(poll.reload.communities).to include another_group.community
      expect(poll.reload.group_id).to eq another_group.id
    end

    it 'does nothing if group community doesnt exist' do
      expect { poll.update(group_id: nil) }.to_not change { poll.communities.count }
    end
  end
end
