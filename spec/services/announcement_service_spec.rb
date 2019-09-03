require 'rails_helper'

describe AnnouncementService do

  describe 'resend_pending_invitations' do
    let(:user) { create(:user) }
    let(:group) { build(:formal_group) }
    let(:membership) { create :membership, accepted_at: nil, group: group, created_at: (24.hours.ago - 30.minutes) }
    let(:event) {
      Events::AnnouncementCreated.publish!(
        group,
        user,
        Membership.where(id: membership.id),
        :group_announced
      )
    }

    before { event.update created_at: (24.hours.ago.beginning_of_hour - 30.minutes) }

    it 'resends invitations after a specified period' do
      expect { AnnouncementService.resend_pending_invitations }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'can specify a time period' do
      event.update_attributes(created_at: 10.hours.ago)
      expect { AnnouncementService.resend_pending_invitations(since: 11.hours.ago, till: 9.hours.ago) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not resend accepted invitations' do
      membership.update_attributes(accepted_at: Time.now)
      expect { AnnouncementService.resend_pending_invitations }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend invitations outside specified period' do
      event.update_attributes(created_at: 10.hours.ago)
      expect { AnnouncementService.resend_pending_invitations }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  describe 'create' do
    let!(:group) { create :formal_group }
    let!(:discussion) { create :discussion, group: group }
    let!(:poll) { create :poll, discussion: discussion }
    let!(:user) { create :user }

    describe 'undecided_count' do
      before do
        poll.update_undecided_count
        group.add_admin! user
      end

      it 'updates poll undecided count when inviting to group' do
        expect { AnnouncementService.create(model: group, actor: user, params: {
          kind: :group_announced,
          recipients: { user_ids: [create(:user).id] }
        }) }.to change { poll.reload.undecided_count }.by(1)
      end

      it 'updates poll undecided count when inviting to discussion' do
        expect { AnnouncementService.create(model: discussion, actor: user, params: {
          kind: :discussion_announced,
          recipients: { user_ids: [create(:user).id] }
        }) }.to change { poll.reload.undecided_count }.by(1)
      end

      it 'updates poll undecided count when inviting to poll' do
        expect { AnnouncementService.create(model: poll, actor: user, params: {
          kind: :poll_announced,
          recipients: { user_ids: [create(:user).id] }
        }) }.to change { poll.reload.undecided_count }.by(1)
      end

      it 'updates poll undecided count when making an invitation' do
        expect { AnnouncementService.create(model: group, actor: user, params: {
          kind: :group_announced,
          recipients: { emails: ['test@test.com'] }
        }) }.to change { poll.reload.undecided_count }.by(1)
      end

      it 'does not change the undecided count of a closed poll' do
        poll.update(closed_at: 1.day.ago)
        expect { AnnouncementService.create(model: group, actor: user, params: {
          kind: :group_announced,
          recipients: { user_ids: [create(:user).id] }
        }) }.to_not change { poll.reload.undecided_count }
      end
    end
  end
end
