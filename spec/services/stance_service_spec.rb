require 'rails_helper'

describe StanceService do
  let(:agree) { create :poll_option, poll: poll, name: "agree" }
  let(:disagree) { create :poll_option, poll: poll, name: "disagree" }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:proposal) { create :poll_proposal, discussion: discussion }
  let(:public_poll) { create :poll, anyone_can_participate: true }
  let(:public_stance) { build :stance, poll: public_poll, stance_choices: [agree_choice], participant: nil }
  let(:user) { create :user }
  let(:another_group_member) { create :user }
  let(:another_user) { create :user }
  let(:stance) { create :stance, poll: poll, stance_choices: [agree_choice], participant: user, reason: "Old one" }
  let(:another_stance) { create :stance, poll: poll, stance_choices: [disagree_choice], participant: another_group_member }
  let(:stance_created) { build :stance, poll: poll, stance_choices: [agree_choice], participant: nil }
  let(:agree_choice) { build(:stance_choice, poll_option: agree) }
  let(:disagree_choice) { build(:stance_choice, poll_option: disagree) }
  let(:poll_created_event) { PollService.create(poll: poll, actor: user) }

  before do
    discussion.created_event
    group.add_member! user
    group.add_member! another_group_member
  end

  describe 'create' do
    it 'creates a new stance' do
      expect { StanceService.create(stance: stance_created, actor: user) }.to change { Stance.count }.by(1)
    end

    it 'does not create an invalid stance' do
      stance_created.poll_id = proposal.id
      stance_created.stance_choices = []
      expect { StanceService.create(stance: stance_created, actor: user) }.to_not change { Stance.count }
    end

    it 'updates existing stances for that user to no longer be latest' do
      stance
      StanceService.create(stance: stance_created, actor: user)
      expect(stance.reload.latest).to eq false
      expect(another_stance.reload.latest).to eq true
      expect(stance_created.reload.latest).to eq true
    end

    it 'sets event parent to the poll created event' do
      poll_created_event
      event = StanceService.create(stance: stance_created, actor: user)
      expect(event.parent.id).to eq poll_created_event.id
    end

    it 'does not create a stance for a logged out user' do
      expect { StanceService.create(stance: public_stance, actor: LoggedOutUser.new) }.to_not change { Stance.count }
    end

    it 'does not allow visitors to create unauthorized stances' do
      expect { StanceService.create(stance: stance_created, actor: visitor) }.to raise_error { CanCan::AccessDenied }
    end

    it 'does not allow an unauthorized member to create a stance' do
      expect { StanceService.create(stance: stance_created, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    it 'updates stance data on the poll' do
      expect { StanceService.create(stance: stance_created, actor: user) }.to change { poll.stance_data['agree'].to_i }.by(1)
    end

    it 'does not include old stance data on the poll' do
      stance
      poll.update_stance_data
      expect { StanceService.create(stance: stance_created, actor: user) }.to_not change { poll.stance_data['agree'].to_i }
    end

    describe 'notify_on_participate' do
      it 'emails the poll author when notify_on_participate is true' do
        stance_created.poll.update(notify_on_participate: true)
        expect { StanceService.create(stance: stance_created, actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'notifies the poll author when notify_on_participate is true' do
        stance_created.poll.update(notify_on_participate: true)
        expect { StanceService.create(stance: stance_created, actor: user) }.to change { stance_created.poll.author.notifications.count }.by(1)
      end

      it 'does not email the poll author when notify_on_participate is false' do
        expect { StanceService.create(stance: stance_created, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'does not notify the poll author when notify_on_participate is false' do
        expect { StanceService.create(stance: stance_created, actor: user) }.to_not change { stance_created.poll.author.notifications.count }
      end
    end
  end
end
