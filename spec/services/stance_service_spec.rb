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
  let(:visitor) { build :visitor }
  let(:another_group_member) { create :user }
  let(:another_user) { create :user }
  let(:stance) { create :stance, poll: poll, stance_choices: [agree_choice], participant: user, reason: "Old one" }
  let(:another_stance) { create :stance, poll: poll, stance_choices: [disagree_choice], participant: another_group_member }
  let(:stance_created) { build :stance, poll: poll, stance_choices: [agree_choice], participant: nil }
  let(:agree_choice) { build(:stance_choice, poll_option: agree) }
  let(:disagree_choice) { build(:stance_choice, poll_option: disagree) }

  before do
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

    it 'can create a stance with a visitor' do
      expect { StanceService.create(stance: public_stance, actor: visitor) }.to change { Stance.count }.by(1)
      expect(visitor.reload.persisted?).to eq true
      expect(public_stance.reload.participant).to eq visitor
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
  end
end
