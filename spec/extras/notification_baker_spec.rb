require 'rails_helper'

describe NotificationBaker do
  let(:user) { create :user }
  let(:admin) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }
  let(:event) { Events::MotionClosingSoon.publish!(motion) }
  let(:added_event) { Events::UserAddedToGroup.publish!(Membership.find_by(user: user, group: group), admin) }
  let(:notification) { Notification.find_by(event: event, user: user) }
  let(:added_notification) { Notification.find_by(event: added_event, user: user) }
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

  it 'handles user_added_to_group correctly' do
    group.add_admin! admin
    added_notification.update_attribute(:url, nil)
    added_notification.update_attribute(:translation_values, {})
    subject
    expect(added_notification.reload.url).to be_present
    expect(added_notification.translation_values).to be_present
  end

  it 'does not error if added_to_group does not have an eventable' do
    group.add_admin! admin
    added_notification.update_attribute(:url, nil)
    added_notification.update_attribute(:translation_values, {})
    added_notification.update_attribute(:event_id, nil)
    subject
    expect(added_notification.reload.url).to_not be_present
    expect(added_notification.translation_values).to_not be_present
  end

  it 'does not error if the notification does not have an event' do
    notification.update_attribute(:event_id, nil)
    subject
    expect(notification.reload.url).to_not be_present
    expect(notification.translation_values).to_not be_present
  end

  it 'does not error if the notification does not have an event' do
    notification.event.update_attribute(:eventable_id, nil)
    subject
    expect(notification.url).to_not be_present
    expect(notification.translation_values).to_not be_present
  end

  it 'does not do anything for unsupported notification kinds' do
    notification.event.update_attribute(:kind, 'not_a_kind')
    subject
    expect(notification.reload.url).to_not be_present
    expect(notification.translation_values).to_not be_present
  end
end
