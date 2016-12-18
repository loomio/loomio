require 'rails_helper'

describe PollService do
  let(:new_poll) { build :poll, poll_template: poll_template }
  let(:poll) { create :poll, poll_template: poll_template }
  let(:poll_template) { create :poll_template, poll_options: [create(:poll_option)]}
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:vote) { create :vote, motion: motion, statement: "I am a statement" }
  let(:visitor) { LoggedOutUser.new }
  let(:group) { create :group }
  let(:group_reference) { PollReferences::Group.new(group) }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:discussion_reference) { PollReferences::Discussion.new(discussion) }

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
      PollService.create(poll: new_poll, actor: user, communities: [group.community], reference: group_reference)

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
      expect { PollService.create(poll: new_poll, actor: another_user, reference: group_reference) }.to raise_error { CanCan::AccessDenied }
    end

    it 'creates a poll which references the group community' do
      PollService.create(poll: new_poll, actor: user, reference: group_reference)

      poll = Poll.last
      expect(poll.communities.length).to eq 1
      expect(poll.communities).to include group.community
      expect(group.polls).to include poll
    end

    it 'creates a poll which references the group community from a discussion' do
      PollService.create(poll: new_poll, actor: user, reference: discussion_reference)

      poll = Poll.last
      expect(poll.communities.length).to eq 1
      expect(poll.communities).to include group.community
      expect(poll.discussion).to eq discussion
      expect(poll.group).to eq discussion.group
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

  describe 'convert' do
    before { vote; motion.save }

    it 'creates a poll from an active motion' do
      expect { PollService.convert(motions: motion) }.to change { Poll.count }.by(1)
      poll = Poll.last

      expect(poll.motion).to eq motion
      expect(poll.discussion).to eq motion.discussion
      expect(poll.group).to eq motion.group
      expect(group.polls).to include poll
      expect(discussion.polls).to include poll
      expect(poll.closing_at).to eq motion.closing_at
      expect(poll.closed_at).to eq motion.closed_at
      expect(poll.users).to eq motion.voters
      expect(poll.poll_template).to eq PollTemplate.motion_template
      expect(poll.poll_options.map(&:name).sort).to eq ['abstain', 'agree', 'block', 'disagree']
      expect(poll.stances.count).to eq motion.votes.count
      expect(poll.stances.first.statement).to eq vote.statement
    end

    it 'does not alter the existing motion' do
      PollService.convert(motions: motion)
      expect(motion.reload).to eq motion
    end

    it 'uses the groups community for voting motions' do
      PollService.convert(motions: motion)
      group.add_member! another_user

      poll = Poll.last
      expect(poll.communities.count).to eq 1
      expect(poll.communities).to include motion.group.community
      expect(poll.communities.first.includes?(vote.user)).to eq true
      expect(poll.communities.first.includes?(another_user)).to eq true
    end

    it 'creates a new community based on the participants for closed motions' do
      motion.close!
      PollService.convert(motions: motion)
      group.add_member! another_user

      poll = Poll.last
      expect(poll.communities.count).to eq 1
      expect(poll.communities.first).to be_a Communities::LoomioUsers
      expect(poll.communities.first.includes?(vote.user)).to eq true
      expect(poll.communities.first.includes?(another_user)).to eq false
    end

    it 'does not create duplicate polls for the same motion' do
      PollService.convert(motions: motion)
      expect { PollService.convert(motions: motion) }.to_not change { Poll.count }
    end
  end

  describe 'close' do
    it 'closes a poll' do
      PollService.create(poll: new_poll, actor: user)
      PollService.close(poll: new_poll)
      expect(new_poll.reload.closed_at).to be_present
    end

    it 'disallows the creation of new stances' do
      PollService.create(poll: new_poll, actor: user)
      new_stance = build(:stance, poll: new_poll)
      expect(user.ability.can?(:create, new_stance)).to eq true
      PollService.close(poll: new_poll)
      expect(user.ability.can?(:create, new_stance)).to eq false
    end

    it 'freezes the possible participants from a group' do
      PollService.create(poll: new_poll, actor: user, reference: group_reference)
      PollService.close(poll: new_poll)
      group.add_member! another_user
      expect(new_poll.reload.communities.first.includes?(another_user)).to eq false
    end
  end
end
