require 'rails_helper'

describe PollService do
  let(:new_poll) { build :poll, discussion: discussion }
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
  let(:stance) { create :stance, poll: new_poll }

  before { group.add_member! user }

  describe '#create' do
    it 'creates a new poll' do
      expect { PollService.create(poll: new_poll, actor: user) }.to change { Poll.count }.by(1)
    end

    # it 'populates a public community if no reference is given' do
    #   PollService.create(poll: new_poll, actor: user)
    #
    #   poll = Poll.last
    #   expect(poll.communities.count).to eq 1
    #   expect(poll.communities.last).to be_a Communities::Public
    # end

    it 'populates removing custom poll actions' do
      new_poll.poll_options_attributes = [{ name: "agree"}]
      PollService.create(poll: new_poll, actor: user)

      poll = Poll.last
      expect(poll.poll_options.count).to eq 1
      expect(poll.poll_options)
    end

    it 'does not allow adding custom proposal actions' do
      new_poll.poll_options_attributes = [{name: "superagree"}]
      expect { PollService.create(poll: new_poll, actor: user) }.to_not change { Poll.count }
    end

    it 'does not create an invalid poll' do
      new_poll.title = ''
      expect { PollService.create(poll: new_poll, actor: user) }.to_not change { Poll.count }
    end

    it 'does not allow visitors to create polls' do
      expect { PollService.create(poll: new_poll, actor: visitor) }.to raise_error { CanCan::AccessDenied }
    end

    # it 'creates a poll which references the group community' do
    #   PollService.create(poll: new_poll, actor: user, reference: group)
    #
    #   poll = Poll.last
    #   expect(poll.communities.length).to eq 1
    #   expect(poll.communities).to include group.community
    #   expect(group.polls).to include poll
    # end
    #
    # it 'creates a poll which references the group community from a discussion' do
    #   PollService.create(poll: new_poll, actor: user, reference: discussion)
    #
    #   poll = Poll.last
    #   expect(poll.communities.length).to eq 1
    #   expect(poll.communities).to include group.community
    #   expect(poll.discussion).to eq discussion
    #   expect(poll.group).to eq discussion.group
    #   expect(group.polls).to include poll
    #   expect(discussion.polls).to include poll
    # end

    # it 'does not allow users to create polls for communities they are not a part of' do
    #   expect { PollService.create(poll: new_poll, actor: another_user, reference: group) }.to raise_error { CanCan::AccessDenied }
    # end

    describe 'announcements' do
      it 'announces the poll to a group' do
        new_poll.make_announcement = true
        expect { PollService.create(poll: new_poll, actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'does not announce unless make_announcement is set to true' do
        expect { PollService.create(poll: new_poll, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end

      # it 'does not announce if a group is not specified' do
      #   new_poll.make_announcement = true
      #   expect { PollService.create(poll: new_poll, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      # end
    end

  end

  # describe 'set_communities' do
  #   before { PollService.create(poll: new_poll, actor: user) }

    # it 'sets the communities of the poll' do
    #   PollService.set_communities(poll: new_poll, actor: user, communities: [group.community])
    #   expect(new_poll.communities.length).to eq 1
    #   expect(new_poll.communities).to include group.community
    # end

    # it 'does not allow the communities to change once voting has begun' do
    #   stance
    #   expect { PollService.set_communities(poll: new_poll, actor: user, communities: [group.community]) }.to raise_error { CanCan::AccessDenied }
    #   expect(new_poll.communities).to_not include group.community
    # end

    # it 'does not allow anyone other than the author to change communities' do
    #   expect { PollService.set_communities(poll: new_poll, actor: another_user, communities: [group.community]) }.to raise_error { CanCan::AccessDenied }
    #   expect(new_poll.reload.communities.first).to be_a Communities::Public
    # end

    # it 'does not allow adding communities the author is not a part of' do
    #   expect { PollService.set_communities(poll: new_poll, actor: user, communities: [another_group.community] ) }.to raise_error { CanCan::AccessDenied }
    # end

    # it 'does not allow removing all communities' do
    #   PollService.set_communities(poll: new_poll, actor: user, communities: [])
    #   expect(new_poll.communities.count).to eq 1
    #   expect(new_poll.communities.first).to be_a Communities::Public
    # end
  # end

  describe '#update' do
    before { PollService.create(poll: new_poll, actor: user) }

    it 'updates an existing poll' do
      PollService.update(poll: new_poll, params: { details: "A new description" }, actor: user)
      expect(new_poll.reload.details).to eq "A new description"
    end

    it 'does not allow randos to edit proposals' do
      expect { PollService.update(poll: new_poll, params: { details: "A new description" }, actor: another) }.to raise_error { CanCan::AccessDenied }
      expect(new_poll.reload.details).to_not eq "A new description"
    end

    it 'does not save an invalid poll' do
      old_title = new_poll.title
      PollService.update(poll: new_poll, params: { title: "" }, actor: user)
      expect(new_poll.reload.title).to eq old_title
    end

    it 'makes an announcement to participants if make_announcement is true' do
      stance
      expect {
        PollService.update(poll: new_poll, params: { details: "A new description", make_announcement: true }, actor: user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
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
      expect(poll.outcome).to be_nil
    end

    it 'saves an outcome on a closed motion' do
      PollService.convert(motions: closed_motion)
      poll = Poll.last
      expect(poll.outcome.statement).to eq closed_motion.outcome
      expect(poll.outcome.author).to eq closed_motion.outcome_author
    end

    it 'does not alter the existing motion' do
      PollService.convert(motions: motion)
      expect(motion.reload).to eq motion
    end

    # it 'uses the groups community for voting motions' do
    #   PollService.convert(motions: motion)
    #   group.add_member! another_user
    #
    #   poll = Poll.last
    #   expect(poll.communities.count).to eq 1
    #   expect(poll.communities).to include motion.group.community
    #   expect(poll.communities.first.includes?(vote.user)).to eq true
    #   expect(poll.communities.first.includes?(another_user)).to eq true
    # end

    # it 'creates a new community based on the participants for closed motions' do
    #   motion.close!
    #   PollService.convert(motions: motion)
    #   group.add_member! another_user
    #
    #   poll = Poll.last
    #   expect(poll.communities.count).to eq 1
    #   expect(poll.communities.first).to be_a Communities::LoomioUsers
    #   expect(poll.communities.first.includes?(vote.user)).to eq true
    #   expect(poll.communities.first.includes?(another_user)).to eq false
    # end

    it 'does not create duplicate polls for the same motion' do
      PollService.convert(motions: motion)
      expect { PollService.convert(motions: motion) }.to_not change { Poll.count }
    end
  end

  describe 'close', focus: true do
    it 'closes a poll' do
      PollService.create(poll: new_poll, actor: user)
      PollService.close(poll: new_poll, actor: user)
      expect(new_poll.reload.closed_at).to be_present
    end

    it 'disallows the creation of new stances' do
      PollService.create(poll: new_poll, actor: user)
      new_stance = build(:stance, poll: new_poll)
      expect(user.ability.can?(:create, new_stance)).to eq true
      PollService.close(poll: new_poll, actor: user)
      expect(user.ability.can?(:create, new_stance)).to eq false
    end

    # it 'freezes the possible participants from a group' do
    #   PollService.create(poll: new_poll, actor: user, reference: group)
    #   PollService.close(poll: new_poll)
    #   group.add_member! another_user
    #   expect(new_poll.reload.communities.first.includes?(another_user)).to eq false
    # end
  end

  describe 'expire_lapsed_polls', focus: true do
    it 'expires a lapsed poll' do
      PollService.create(poll: new_poll, actor: user)
      new_poll.update_attribute(:closing_at,1.day.ago)
      PollService.expire_lapsed_polls
      expect(new_poll.reload.closed_at).to be_present
    end

    it 'does not expire active poll' do
      PollService.create(poll: new_poll, actor: user)
      PollService.expire_lapsed_polls
      expect(new_poll.reload.closed_at).to_not be_present
    end

    it 'does not touch closed polls' do
      PollService.create(poll: new_poll, actor: user)
      new_poll.update_attributes(closing_at: 1.day.ago, closed_at: 1.day.ago)
      expect { PollService.expire_lapsed_polls }.to_not change { new_poll.reload.closed_at }
    end
  end
end
