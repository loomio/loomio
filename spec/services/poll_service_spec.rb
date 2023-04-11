require 'rails_helper'

describe PollService do
  let(:poll_created) { build :poll, discussion: discussion }
  let(:public_poll) { build :poll }
  let(:private_poll) { build :poll }
  let(:poll) { create :poll, discussion: discussion }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group }

  let(:discussion) { create :discussion, group: group }
  let(:stance) { create :stance, poll: poll_created, choice: poll_created.poll_options.first.name, reason: 'good idea' }
  let(:identity) { create :slack_identity }


  before { group.add_member!(user) }

  describe 'create_stances' do
    let(:actor) { create :user, name: 'actor'}
    let(:member) { create :user, name: 'member' }

    before do
      group.add_admin! actor
      group.add_member! member
      poll
    end

    it 'starts with 0 stances' do
      expect(Stance.where(participant_id: member.id).count).to eq 0
    end

    it 'creates stance by id' do
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).count).to eq 1
    end

    it 'creates stance by email' do
      PollService.create_stances(poll: poll, actor: actor, emails: [member.email])
      expect(Stance.where(participant_id: member.id).count).to eq 1
    end

    it 'creates stance by audience' do
      PollService.create_stances(poll: poll, actor: actor, audience: 'group')
      expect(Stance.where(participant_id: member.id).count).to eq 1
    end

    it 'only creates stances for users who dont have a stance already' do
      expect(Stance.where(participant_id: member.id).count).to eq 0
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).count).to eq 1
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).count).to eq 1
      PollService.create_stances(poll: poll, actor: actor, emails: [member.email])
      expect(Stance.where(participant_id: member.id).count).to eq 1
      PollService.create_stances(poll: poll, actor: actor, audience: 'group')
      expect(Stance.where(participant_id: member.id).count).to eq 1
    end

    it 'reinvites revoked users' do
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      stance = Stance.where(poll: poll, participant: member.id).first
      membership = Membership.where(group: poll.group, user: member).first
      expect(stance.reload.revoked_at).to be nil
      MembershipService.destroy(membership: membership, actor: poll.group.admins.first)
      expect(stance.reload.revoked_at).to be_present
      poll.group.add_member!(member)
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(stance.reload.revoked_at).to be_nil
    end

    it 'uses normal volume by default' do
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).first.volume).to eq 'normal'
    end

    it 'uses discussion reader volume if quiet' do
      DiscussionReader.create(user_id: member.id, discussion_id: discussion.id, volume: 'quiet')
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).first.volume).to eq 'quiet'
    end

    it 'uses normal volume if discussion reader loud' do
      DiscussionReader.create(user_id: member.id, discussion_id: discussion.id, volume: 'loud')
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).first.volume).to eq 'normal'
    end

    it 'uses membership volume if quiet' do
      DiscussionReader.delete_all
      Membership.where(user_id: member.id).update_all(volume: 'quiet')
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).first.volume).to eq 'quiet'
    end

    it 'uses reader volume before membership volume' do
      Membership.where(user_id: member.id).update_all(volume: 'normal')
      DiscussionReader.create(user_id: member.id, discussion_id: discussion.id, volume: 'quiet')
      PollService.create_stances(poll: poll, actor: actor, user_ids: [member.id])
      expect(Stance.where(participant_id: member.id).first.volume).to eq 'quiet'
    end
  end

  describe '#create' do
    it 'creates a new poll' do
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)
    end

    it 'populates removing custom poll actions' do
      poll_created.poll_type = 'poll'
      poll_created.poll_options = []
      poll_created.poll_option_names = ["green"]
      expect { PollService.create(poll: poll_created, actor: user) }.to change { Poll.count }.by(1)

      expect(poll_created.reload.poll_options.count).to eq 1
      expect(poll_created.poll_options.first.name).to eq "green"
    end

    # it 'does not allow adding custom proposal actions' do
    #   poll_created.poll_type = 'proposal'
    #   poll_created.poll_option_names = ["superagree"]
    #   expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    # end

    it 'does not create an invalid poll' do
      poll_created.title = ''
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { Poll.count }
    end

    it 'does not allow users to create polls they are not allowed to' do
      expect { PollService.create(poll: poll_created, actor: another_user) }.to raise_error CanCan::AccessDenied
    end

    it 'does not email people' do
      expect { PollService.create(poll: poll_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'notifies new mentions' do
      poll.group.add_member! another_user
      poll.details = "A mention for @#{another_user.username}!"
      expect { PollService.create(poll: poll, actor: user) }.to change {
        Events::UserMentioned.where(kind: :user_mentioned).count
      }.by(1)
    end

  end

  describe '#update' do
    before { PollService.create(poll: poll_created, actor: user) }

    it 'updates an existing poll' do
      PollService.update(poll: poll_created, params: { details: "A new description" }, actor: user)
      expect(poll_created.reload.details).to eq "A new description"
    end

    it 'does not allow randos to edit proposals' do
      expect { PollService.update(poll: poll_created, params: { details: "A new description" }, actor: another_user) }.to raise_error CanCan::AccessDenied
      expect(poll_created.reload.details).to_not eq "A new description"
    end

    it 'does not save an invalid poll' do
      old_title = poll_created.title
      PollService.update(poll: poll_created, params: { title: "" }, actor: user)
      expect(poll_created.reload.title).to eq old_title
    end

    it 'doesnt email people' do
      stance
      expect {
        PollService.update(poll: poll_created, params: { details: "A new description" }, actor: user)
      }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'creates a new poll edited event for poll option changes' do
      expect {
        PollService.update(poll: poll_created, params: { poll_option_names: ["new_option"] }, actor: user)
      }.to change { Events::PollEdited.where(kind: :poll_edited).count }.by(1)
    end

    it 'creates a new poll edited event for major changes' do
      expect {
        PollService.update(poll: poll_created, params: { title: "BIG CHANGES!" }, actor: user)
      }.to change { Events::PollEdited.where(kind: :poll_edited).count }.by(1)
    end
  end

  describe 'add_options' do
    before { poll.update(voter_can_add_options: true) }

    it 'adds new poll options' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: user)
      }.to change { poll.poll_options.count }.by(1)
      expect(poll.reload.poll_option_names).to include 'new_option'
      expect(Event.last.kind).to eq 'poll_option_added'
    end

    it 'does not update when poll does not accept new options' do
      poll.update(voter_can_add_options: false)
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: user)
      }.to raise_error CanCan::AccessDenied
      expect(poll.reload.poll_option_names).to_not include 'new_option'
    end

    it 'does not update when no new options are passed' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: [] }, actor: user)
      }.to_not change { Event.count }
    end

    it 'does not update for unauthorized user' do
      expect {
        PollService.add_options(poll: poll, params: { poll_option_names: ['new_option'] }, actor: another_user)
      }.to raise_error CanCan::AccessDenied
    end
  end

  describe 'close' do
    it 'closes a poll' do
      PollService.create(poll: poll_created, actor: user)
      PollService.close(poll: poll_created, actor: user)
      expect(poll_created.reload.closed_at).to be_present
    end

    it 'does not allow change from anonymous to normal' do
      poll_created.anonymous = true
      expect(poll_created.save).to eq true
      poll_created.anonymous = false
      expect(poll_created.save).to eq false
    end

    it 'does not allow results early if hidden' do
      poll_created.hide_results = :until_closed
      expect(poll_created.save).to eq true
      poll_created.hide_results = :off
      expect(poll_created.save).to eq false
    end


    it 'removes user from stance and event after close' do
      poll_created.anonymous = true
      PollService.create(poll: poll_created, actor: user)
      stance

      StanceService.create(stance: stance, actor: stance.real_participant)
      expect(stance.real_participant).to be_present
      expect(stance.participant_id).to_not be nil
      expect(stance.created_event.user_id).to be nil
      expect(stance.participant).to be_a AnonymousUser
      expect(stance.created_event.user).to be_a AnonymousUser
      PollService.close(poll: poll_created, actor: user)
      expect(stance.reload.participant).to be_a AnonymousUser
      expect(stance.created_event.reload.user).to be_a AnonymousUser
      expect(stance.participant_id).to be nil
      expect(stance.created_event.user_id).to be nil
    end


    it 'does not removes user from stance when no anonymous' do
      PollService.create(poll: poll_created, actor: user)
      stance
      StanceService.create(stance: stance, actor: stance.participant)
      expect(stance.participant).to be_present
      PollService.close(poll: poll_created, actor: user)
      expect(stance.reload.participant).to be_present
      expect(stance.created_event.reload.user).to be_present
    end

    it 'stances_in_discussion is false' do
      poll_created.hide_results = :until_closed
      PollService.create(poll: poll_created, actor: user)
      event = StanceService.create(stance: stance, actor: stance.participant)
      expect(event.discussion).to be nil
      PollService.close(poll: poll_created, actor: user)
      expect(event.reload.discussion_id).to be_present

    end

    it 'hides and reveals results correctly' do
      poll_created.hide_results = 'until_closed'
      PollService.create(poll: poll_created, actor: user)

      StanceService.create(stance: stance, actor: stance.participant)
      expect(PollSerializer.new(poll_created).as_json[:poll][:stance_counts]).to be nil
      PollService.close(poll: poll_created, actor: user)

      poll_created.reload
      expect(PollSerializer.new(poll_created).as_json[:poll][:stance_counts]).to eq [1]
    end

    it 'disallows the creation of new stances' do
      PollService.create(poll: poll_created, actor: user)
      stance_created = build(:stance, poll: poll_created)
      expect(user.ability.can?(:create, stance_created)).to eq true
      PollService.close(poll: poll_created, actor: user)
      expect(user.ability.can?(:create, stance_created)).to eq false
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
      poll_created.update(closing_at: 1.day.ago, closed_at: 1.day.ago)
      expect { PollService.expire_lapsed_polls }.to_not change { poll_created.reload.closed_at }
    end
  end

  describe '#cleanup_examples' do
    it 'removes example polls' do
      create(:poll, example: true, created_at: 2.days.ago)
      expect { PollService.cleanup_examples }.to change { Poll.count }.by(-1)
    end

    it 'does not remove recent example polls' do
      create(:poll, example: true, created_at: 30.minutes.ago)
      expect { PollService.cleanup_examples }.to_not change { Poll.count }
    end

    it 'does not remove non-example polls' do
      create(:poll, created_at: 2.days.ago)
      expect { PollService.cleanup_examples }.to_not change { Poll.count }
    end
  end
end
