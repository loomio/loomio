require 'rails_helper'

describe StanceService do
  let(:agree) { create :poll_option, poll: poll, name: "agree" }
  let(:disagree) { create :poll_option, poll: poll, name: "disagree" }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:user) { create :user }
  let(:another_group_member) { create :user }
  let(:another_user) { create :user }
  let(:stance) { create :stance, poll: poll, stance_choices: [agree_choice], participant: user, reason: "Old one" }
  let(:another_stance) { create :stance, poll: poll, stance_choices: [disagree_choice], participant: another_group_member }
  let(:new_stance) { build :stance, poll: poll, stance_choices: [agree_choice], participant: nil }
  let(:agree_choice) { build(:stance_choice, poll_option: agree) }
  let(:disagree_choice) { build(:stance_choice, poll_option: disagree) }

  before do
    group.add_member! user
    group.add_member! another_group_member
  end

  describe 'create' do
    it 'creates a new stance' do
      expect { StanceService.create(stance: new_stance, actor: user) }.to change { Stance.count }.by(1)
    end

    it 'does not create an invalid stance' do
      new_stance.stance_choices = []
      expect { StanceService.create(stance: new_stance, actor: user) }.to_not change { Stance.count }
    end

    it 'updates existing stances for that user to no longer be latest' do
      stance
      StanceService.create(stance: new_stance, actor: user)
      expect(stance.reload.latest).to eq false
      expect(another_stance.reload.latest).to eq true
      expect(new_stance.reload.latest).to eq true
    end

    it 'does not allow an unauthorized member to create a stance' do
      expect { StanceService.create(stance: new_stance, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    it 'updates stance data on the poll' do
      expect { StanceService.create(stance: new_stance, actor: user) }.to change { poll.stance_data['agree'].to_i }.by(1)
    end

    it 'does not include old stance data on the poll' do
      stance
      poll.update_stance_data
      expect { StanceService.create(stance: new_stance, actor: user) }.to_not change { poll.stance_data['agree'].to_i }
    end
  end
end
