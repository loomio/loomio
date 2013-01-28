describe NotificationItems::MotionClosingSoon do
  let(:notification) { stub(:notification) }
  let(:item) { NotificationItems::MotionClosingSoon.new(notification) }

  it "#actor returns the current user" do
    user = stub(:user)
    notification.stub_chain(:eventable, :user).and_return(user)
    item.actor.should == notification.eventable.user
  end

  it "#action_text returns a string" do
    item.action_text.should == I18n.t('notifications.motion_closing_soon') + ": "
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :name).and_return("hello")
    item.title.should == notification.eventable.name
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    item.group_full_name.should == notification.eventable.group_full_name
  end

  it "#link returns a path to the motion" do
    item.stub_chain(:url_helpers, :motion_path).and_return("/motions/1")
    notification.stub(:eventable).and_return(stub(:motion))
    item.link.should == "/motions/1"
  end
end
