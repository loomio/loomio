describe NotificationItems::UserAddedToGroup do
  let(:notification) { stub(:notification) }
  let(:item) { NotificationItems::UserAddedToGroup.new(notification) }

  it "#actor returns the user who has been added to the group" do
    user = stub(:user)
    notification.stub_chain(:eventable, :user).and_return(user)
    item.actor.should == notification.eventable.user
  end

  it "#action_text returns a string" do
    item.action_text.should == I18n.t('notifications.user_added_to_group')
  end

  it "#title returns the groups name" do
    notification.stub_chain(:eventable, :group_full_name).and_return("hello")
    item.title.should == notification.eventable.group_full_name
  end

  it "#group_full_name returns the group name including a parent group if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    item.group_full_name.should == notification.eventable.group_full_name
  end

  it "#link returns a path to the group" do
    item.stub_chain(:url_helpers, :group_path).and_return("/groups/1/")
    notification.stub_chain(:eventable, :group).and_return(stub(:group))
    item.link.should == "/groups/1/"
  end
end
