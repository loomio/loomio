require 'rails_helper'

describe AnnouncementService do

  describe 'resend_pending_memberships' do
    let(:discussion) { create :discussion }
    let(:membership) { create :membership, accepted_at: nil, group: discussion.guest_group, created_at: (24.hours.ago - 30.minutes) }
    let(:event) {
      Events::AnnouncementCreated.publish!(
        discussion,
        discussion.author,
        Membership.where(id: membership.id),
        :new_discussion
      )
    }

    before { event.update created_at: (24.hours.ago - 30.minutes) }

    it 'resends invitations after a specified period' do
      expect { AnnouncementService.resend_pending_memberships }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'can specify a time period' do
      event.update_attributes(created_at: 10.hours.ago)
      expect { AnnouncementService.resend_pending_memberships(since: 11.hours.ago, till: 9.hours.ago) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not resend accepted invitations' do
      membership.update_attributes(accepted_at: Time.now)
      expect { AnnouncementService.resend_pending_memberships }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not resend invitations outside specified period' do
      event.update_attributes(created_at: 10.hours.ago)
      expect { AnnouncementService.resend_pending_memberships }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end
end
