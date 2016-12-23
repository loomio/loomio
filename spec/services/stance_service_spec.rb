require 'rails_helper'

describe StanceService do
  let(:poll_option) { create :poll_option }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:poll) { create :poll, discussion: discussion }
  let(:user) { create :user }
  let(:another_group_member) { create :user }
  let(:another_user) { create :user }
  let(:stance) { create :stance, poll: poll, poll_option: poll_option, participant: user, reason: "Old one" }
  let(:another_stance) { create :stance, poll: poll, poll_option: poll_option, participant: another_group_member }
  let(:new_stance) { build :stance, poll: poll, poll_option: poll_option, participant: nil }

  before do
    group.add_member! user
    group.add_member! another_group_member
  end

  describe 'create' do
    it 'creates a new stance' do
      expect { StanceService.create(stance: new_stance, actor: user) }.to change { Stance.count }.by(1)
    end

    it 'does not create an invalid stance' do
      new_stance.poll_option = nil
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
  end
end
