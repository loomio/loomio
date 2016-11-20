require 'rails_helper'

describe SendAnalyticsEmailJob do
  let!(:motion) { create :motion, closing_at: 24.hours.from_now }
  let(:subject) { SendAnalyticsEmailJob.new.perform }

  let(:engaged_group) do
    create(:group, analytics_enabled: true).tap do |g|
      3.times { create(:discussion, group: g) }
    end
  end
  let(:engaged_subgroup) do
    create(:group, analytics_enabled: true, parent: engaged_group).tap do |g|
      3.times { create(:discussion, group: g) }
    end
  end
  let(:engaged_subgroup_admin) { engaged_subgroup.add_admin!(create(:user)).user }
  let(:engaged_admin) { engaged_group.add_admin!(create(:user)).user }
  let(:another_engaged_admin) { engaged_group.add_admin!(create(:user)).user }

  let(:disengaged_group) { create(:group, analytics_enabled: true) }
  let(:disengaged_admin) { disengaged_group.add_admin!(create(:user)).user }

  describe 'perform' do
    it 'sends emails to engaged admins' do
      engaged_admin; another_engaged_admin
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(engaged_group.admins.count)
    end

    it 'does not send emails to disengaged admins' do
      expect(UserMailer).to_not receive(:analytics)
      subject
    end

    it 'sends emails for subgroups' do
      engaged_subgroup_admin
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(engaged_subgroup.admins.count + engaged_group.admins.count)
    end

    it 'does not send emails when analytics are disabled' do
      engaged_group.update(analytics_enabled: false)
      expect(UserMailer).to_not receive(:analytics)
      subject
    end
  end
end
