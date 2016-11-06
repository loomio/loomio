require 'rails_helper'

describe NotificationBaker do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }
  let(:event) { Events::MotionClosingSoon.publish!(motion) }
  let(:notification) { Notification.find_by(event: event, user: user) }
  subject { NotificationBaker.bake!(user.notifications) }

  before do
    group.add_admin! user
    # simulate an old notification
    notification.update_attribute(:url, nil)
    notification.update_attribute(:translation_values, {})
  end

  it 'bakes old notifications' do
    subject
    expect(notification.reload.url).to be_present
    expect(notification.translation_values).to be_present
  end

  it 'does not error if the notification does not have an event' do
    notification.update_attribute(:event_id, nil)
    subject
    expect(notification.reload.url).to_not be_present
    expect(notification.translation_values).to_not be_present
  end

  it 'does not do anything for unsupported notification kinds' do
    notification.event.update_attribute(:kind, 'not_a_kind')
    subject
    expect(notification.reload.url).to_not be_present
    expect(notification.translation_values).to_not be_present
  end
end
