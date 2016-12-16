require 'rails_helper'

describe PollService do
  let(:new_poll) { build :poll, poll_template: poll_template }
  let(:poll) { create :poll, poll_template: poll_template }
  let(:poll_template) { create :poll_template, poll_options: [create(:poll_option)]}
  let(:user) { create :user }
  let(:visitor) { LoggedOutUser.new }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }

  before { group.add_member! user }

  describe '#create' do
    it 'creates a new poll' do
      expect { PollService.create(poll: new_poll, actor: user) }.to change { Poll.count }.by(1)
    end

    it 'populates a public community if none are given' do
      PollService.create(poll: new_poll, actor: user)

      poll = Poll.last
      expect(poll.communities.count).to eq 1
      expect(poll.communities.last).to be_a Communities::Public
    end

    it 'populates communities if given' do
      PollService.create(poll: new_poll, actor: user, communities: [group.community])

      poll = Poll.last
      expect(poll.communities.count).to eq 1
      expect(poll.communities.last).to eq group.community
    end

    it 'does not duplicate communities' do
      PollService.create(poll: new_poll, actor: user, communities: [group.community], parent: group)

      poll = Poll.last
      expect(poll.communities.count).to eq 1
      expect(poll.communities.last).to eq group.community
    end

    it 'populates polling actions for the new poll' do
      PollService.create(poll: new_poll, actor: user)

      poll = Poll.last
      expect(poll.poll_options.count).to eq 1
      expect(poll.poll_options.last).to eq poll_template.poll_options.last
    end

    it 'does not create an invalid poll' do
      new_poll.name = ''
      expect { PollService.create(poll: new_poll, actor: user) }.to_not change { Poll.count }
    end

    it 'does not allow visitors to create polls' do
      expect { PollService.create(poll: new_poll, actor: visitor) }.to raise_error { CanCan::AccessDenied }
    end

    it 'does not allow users to create polls for communities they are not a part of' do
      expect { PollService.create(poll: new_poll, actor: user, parent: another_group) }.to raise_error { CanCan::AccessDenied }
    end

    it 'creates a poll which references the group community' do
      PollService.create(poll: new_poll, actor: user, parent: group)

      poll = Poll.last
      expect(poll.communities.length).to eq 1
      expect(poll.communities).to include group.community
      expect(group.polls).to include poll
    end

    it 'creates a poll which references the discussion community' do
      PollService.create(poll: new_poll, actor: user, parent: discussion)

      poll = Poll.last
      expect(poll.communities.length).to eq 2
      expect(poll.communities).to include discussion.community
      expect(poll.communities).to include group.community
      expect(group.polls).to include poll
      expect(discussion.polls).to include poll
    end

  end

  describe '#update' do
    it 'updates an existing poll' do

    end

    it 'does not save an invalid poll' do

    end
  end
end
