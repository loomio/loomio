require 'rails_helper'

describe StanceService do
  let(:agree) { create :poll_option, poll: poll, name: "agree" }
  let(:disagree) { create :poll_option, poll: poll, name: "disagree" }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { build :poll, discussion: discussion }
  let(:proposal) { create :poll_proposal, discussion: discussion }
  let(:public_poll) { create :poll, anyone_can_participate: true }
  let(:public_stance) { build :stance, poll: public_poll, stance_choices: [agree_choice], participant: nil }
  let(:user) { create :user }
  let(:voter) { create :user }
  let(:another_group_member) { create :user }
  let(:another_user) { create :user }
  let(:stance) { create :stance, poll: poll, stance_choices: [agree_choice], participant: user, reason: "Old one" }
  let(:another_stance) { create :stance, poll: poll, stance_choices: [disagree_choice], participant: another_group_member, inviter: poll.author }
  let(:stance_created) { build :stance, poll: poll, stance_choices: [agree_choice], reason: 'i agree', participant: nil }
  let(:agree_choice) { build(:stance_choice, poll_option: agree) }
  let(:disagree_choice) { build(:stance_choice, poll_option: disagree) }
  let(:poll_created_event) { PollService.create(poll: poll, actor: user) }

  let(:guest_stance) { create :stance, poll: poll, participant: guest_user, reason: "Old one", inviter: poll.author }
  let(:guest_user) { create :user, email_verified: false }

  before do
    discussion.created_event
    group.add_member! user
    group.add_member! voter
    group.add_member! another_group_member
  end

  describe 'redeem' do
    it 'redeems a guest stance' do
      expect(voter.email_verified).to be true
      expect(guest_stance.participant.email_verified).to be false
      expect(guest_stance.reload.participant).to eq guest_user
      StanceService.redeem(stance: guest_stance, actor: voter)
      expect(guest_stance.reload.participant).to eq voter
    end

    it 'does not redeem stance for another verified user' do
      expect(another_stance.participant).to be another_group_member
      StanceService.redeem(stance: another_stance, actor: voter)
      expect(another_stance.participant).to be another_group_member
    end
  end

  describe 'create' do
    it 'creates a new stance' do
      expect { StanceService.create(stance: stance_created, actor: user) }.to change { Stance.count }.by(1)
    end

    it 'does not create an invalid stance' do
      stance_created.poll_id = proposal.id
      stance_created.stance_choices = []
      expect { StanceService.create(stance: stance_created, actor: user) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'sets event parent to the poll created event' do
      poll_created_event
      event = StanceService.create(stance: stance_created, actor: voter)
      expect(event.parent.id).to eq poll_created_event.id
    end

    it 'does not create a stance for a logged out user' do
      expect { StanceService.create(stance: public_stance, actor: LoggedOutUser.new) }.to raise_error CanCan::AccessDenied
    end

    it 'does not allow an unauthorized member to create a stance' do
      expect { StanceService.create(stance: stance_created, actor: another_user) }.to raise_error CanCan::AccessDenied
    end

    it 'updates total_score on the poll' do
      StanceService.create(stance: stance_created, actor: user)
      expect( poll.total_score ).to eq 1
    end
  end
end
