require 'rails_helper'

describe NotificationItems::UserAddedToGroup do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::UserAddedToGroup.new(notification) }

  it "#actor returns the user who invited or approved the new user into the group" do
    notification.stub_chain(:event, :user).and_return double
    notification.stub_chain(:eventable, :user).and_return double
    expect(item.actor).to eq notification.event.user
  end

  it "#action_text returns a string" do
    expect(item.action_text).to eq I18n.t('notifications.user_added_to_group')
  end

  it "#title returns the groups name" do
    notification.stub_chain(:eventable, :group_full_name).and_return("hello")
    expect(item.title).to eq notification.eventable.group_full_name
  end

  it "#group_full_name returns the group name including a parent group if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    expect(item.group_full_name).to eq notification.eventable.group_full_name
  end

  it "#link returns a path to the group" do
    item.stub_chain(:url_helpers, :group_path).and_return("/groups/1/")
    notification.stub_chain(:eventable, :group).and_return(double(:group))
    expect(item.link).to eq "/groups/1/"
  end
end
