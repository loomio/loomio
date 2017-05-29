require 'rails_helper'

describe PollService do
  let(:poll_created) { build :poll, discussion: discussion }
  let(:public_poll) { build :poll }
  let(:private_poll) { build :poll }
  let(:poll) { create :poll, discussion: discussion }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:closed_motion) { create(:motion, discussion: discussion, closed_at: 1.day.ago, outcome: "an outcome", outcome_author: user) }
  let(:vote) { create :vote, motion: motion, statement: "I am a statement" }
  let(:visitor) { LoggedOutUser.new }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:stance) { create :stance, poll: poll_created, choice: poll_created.poll_options.first.name }
  let(:identity) { create :slack_identity }

  before { group.add_member!(user); group.community }

  describe '#create' do
    it 'creates a new poll' do
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)
    end

    it 'populates an email community by default' do
      PollService.create(poll: private_poll, actor: user)

      poll = Poll.last
      expect(poll.communities.map(&:class)).to include Communities::Email
    end

    it 'populates a public community if the poll is not part of a group' do
      poll.discussion = nil
      PollService.create(poll: poll, actor: user)

      poll = Poll.last
      expect(poll.communities.map(&:class)).to include Communities::Public
      expect(poll.communities.map(&:class)).to include Communities::Email
      expect(poll.anyone_can_participate).to eq true
    end

    it 'does not populate a public community if the poll is part of a group' do
      PollService.create(poll: poll, actor: user)

      poll = Poll.last
      expect(poll.communities.map(&:class)).to_not include Communities::Public
      expect(poll.communities.map(&:class)).to include Communities::Email
      expect(poll.anyone_can_participate).to eq false
    end

    it 'populates removing custom poll actions' do
      poll_created.poll_type = 'poll'
      poll_created.poll_options = []
      poll_created.poll_option_names = ["green"]
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)

      expect(poll_created.reload.poll_options.count).to eq 1
      expect(poll_created.poll_options.first.name).to eq "green"
    end

    it 'does not allow adding custom proposal actions' do
      poll_created.poll_type = 'proposal'
      poll_created.poll_option_names = ["superagree"]
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    end

    it 'does not create an invalid poll' do
      poll_created.title = ''
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    end

    it 'does not allow visitors to create polls' do
      expect { PollService.create(poll: poll_created, actor: visitor) }.to raise_error { CanCan::AccessDenied }
    end

    it 'creates a poll which references the group community from a discussion' do
      PollService.create(poll: poll_created, actor: user)

      poll = Poll.last
      expect(poll.communities).to include group.community
      expect(poll.discussion).to eq discussion
      expect(poll.group).to eq discussion.group
      expect(group.polls).to include poll
      expect(discussion.polls).to include poll
    end

    it 'posts to slack if a slack identity is present' do
      group.community.update(identity: identity)
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Events::PollPublished.where(kind: :poll_published).count }.by(1)
      event = Events::PollPublished.where(kind: :poll_published).last
      expect(event.custom_fields['community_id']).to eq group.community.id
    end

    it 'does not allow users to create polls for communities they are not a part of' do
      expect { PollService.create(poll: poll_created, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    describe 'announcements' do
      it 'announces the poll to a group' do
        poll_created.make_announcement = true
        expect { PollService.create(poll: poll_created, actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(poll_created.group.members.count - 1)
      end

      it 'does not announce unless make_announcement is set to true' do
        expect { PollService.create(poll: poll_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end

      # it 'does not announce if a group is not specified' do
      #   poll_created.make_announcement = true
      #   expect { PollService.create(poll: poll_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      # end
    end

  end

  describe '#update' do
    before { PollService.create(poll: poll_created, actor: user) }

    it 'updates an existing poll' do
      PollService.update(poll: poll_created, params: { details: "A new description" }, actor: user)
      expect(poll_created.reload.details).to eq "A new description"
    end

    it 'does not allow randos to edit proposals' do
      expect { PollService.update(poll: poll_created, params: { details: "A new description" }, actor: another) }.to raise_error { CanCan::AccessDenied }
      expect(poll_created.reload.details).to_not eq "A new description"
    end

    it 'does not save an invalid poll' do
      old_title = poll_created.title
      PollService.update(poll: poll_created, params: { title: "" }, actor: user)
      expect(poll_created.reload.title).to eq old_title
    end

    describe 'group_id=' do
      it 'associates a poll community if changing the group id' do
        PollService.update(poll: poll_created, params: {group_id: group.id}, actor: user)
        expect(poll_created.reload.group).to eq group
        expect(poll_created.communities).to include group.community
      end

      it 'removes an associated poll community if changing the group id' do
        poll_created.update(group: group)
        PollService.update(poll: poll_created, params: {group_id: nil}, actor: user)
        expect(poll_created.reload.communities).to_not include group.community
        expect(poll_created.group).to be_nil
      end

      it 'changes the poll community when changing groups' do
        poll_created.update(group: another_group)
        PollService.update(poll: poll_created, params: {group_id: group.id}, actor: user)
        expect(poll_created.reload.group).to eq group
        expect(poll_created.group_id).to eq group.id
        expect(poll_created.communities).to include group.community
        expect(poll_created.communities).to_not include another_group.community
      end
    end

    it 'makes an announcement to participants if make_announcement is true' do
      stance
      expect {
        PollService.update(poll: poll_created, params: { details: "A new description", make_announcement: true }, actor: user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'creates a new poll edited event for poll option changes' do
      expect {
        PollService.update(poll: poll_created, params: { poll_option_names: ["new_option"] }, actor: user)
      }.to change { Events::PollEdited.count }.by(1)
    end

    it 'creates a new poll edited event for major changes' do
      expect {
        PollService.update(poll: poll_created, params: { title: "BIG CHANGES!" }, actor: user)
      }.to change { Events::PollEdited.count }.by(1)
    end

    it 'does not create a new poll edited event for minor changes' do
      expect {
        PollService.update(poll: poll_created, params: { anyone_can_participate: false }, actor: user)
      }.to_not change { Events::PollEdited.count }
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
      expect(poll.participants).to eq motion.voters
      expect(poll.poll_options.map(&:name).sort).to eq ['abstain', 'agree', 'block', 'disagree']
      expect(poll.stances.count).to eq motion.votes.count
      expect(poll.stances.first.reason).to eq vote.statement
      expect(poll.current_outcome).to be_nil
    end

    it 'saves an outcome on a closed motion' do
      PollService.convert(motions: closed_motion)
      poll = Poll.last
      expect(poll.current_outcome.statement).to eq closed_motion.outcome
      expect(poll.current_outcome.author).to eq closed_motion.outcome_author
    end

    it 'does not alter the existing motion' do
      PollService.convert(motions: motion)
      expect(motion.reload).to eq motion
    end

    it 'uses the groups community for voting motions' do
      PollService.convert(motions: motion)
      group.add_member! another_user

      poll = Poll.last
      expect(poll.communities).to include motion.group.community
      expect(poll.communities.first.includes?(vote.user)).to eq true
      expect(poll.communities.first.includes?(another_user)).to eq true
    end

    it 'creates a new community based on the participants for closed motions' do
      motion.close!
      PollService.convert(motions: motion)
      group.add_member! another_user

      poll = Poll.last
      expect(poll.communities.first).to be_a Communities::LoomioUsers
      expect(poll.communities.first.includes?(vote.user)).to eq true
      expect(poll.communities.first.includes?(another_user)).to eq false
    end

    it 'does not create duplicate polls for the same motion' do
      PollService.convert(motions: motion)
      expect { PollService.convert(motions: motion) }.to_not change { Poll.count }
    end
  end

  describe 'close', focus: true do
    it 'closes a poll' do
      PollService.create(poll: poll_created, actor: user)
      PollService.close(poll: poll_created, actor: user)
      expect(poll_created.reload.closed_at).to be_present
    end

    it 'disallows the creation of new stances' do
      PollService.create(poll: poll_created, actor: user)
      stance_created = build(:stance, poll: poll_created)
      expect(user.ability.can?(:create, stance_created)).to eq true
      PollService.close(poll: poll_created, actor: user)
      expect(user.ability.can?(:create, stance_created)).to eq false
    end

    it 'freezes the possible participants from a group' do
      PollService.create(poll: poll_created, actor: user)
      PollService.close(poll: poll_created, actor: user)
      group.add_member! another_user
      expect(poll_created.reload.communities.first.includes?(another_user)).to eq false
    end
  end

  describe 'expire_lapsed_polls' do
    it 'expires a lapsed poll' do
      PollService.create(poll: poll_created, actor: user)
      poll_created.update_attribute(:closing_at,1.day.ago)
      PollService.expire_lapsed_polls
      expect(poll_created.reload.closed_at).to be_present
    end

    it 'does not expire active poll' do
      PollService.create(poll: poll_created, actor: user)
      PollService.expire_lapsed_polls
      expect(poll_created.reload.closed_at).to_not be_present
    end

    it 'does not touch closed polls' do
      PollService.create(poll: poll_created, actor: user)
      poll_created.update_attributes(closing_at: 1.day.ago, closed_at: 1.day.ago)
      expect { PollService.expire_lapsed_polls }.to_not change { poll_created.reload.closed_at }
    end
  end

  describe '#toggle_subscription' do
    it 'toggles a subscription on' do
      PollService.toggle_subscription(poll: poll, actor: user)
      expect(poll.reload.unsubscribers).to include user
    end

    it 'toggles a subscription off' do
      poll.unsubscribers << user
      PollService.toggle_subscription(poll: poll, actor: user)
      expect(poll.reload.unsubscribers).to_not include user
    end

    it 'does nothing if the user doesnt have access' do
      expect { PollService.toggle_subscription(poll: poll, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end
  end
end
