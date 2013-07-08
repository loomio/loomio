describe NotificationItems::MotionEdited do
  let(:notification) { stub(:notification) }
  let(:item) { NotificationItems::MotionEdited.new(notification) }

  it "#actor returns the current user" do
    user = stub(:user)
    notification.stub_chain(:eventable, :user).and_return(user)
    item.actor.should == notification.eventable.user
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :name).and_return("hello")
    item.title.should == notification.eventable.name
  end

  it "#link returns a path to the motion" do
    item.stub_chain(:url_helpers, :motion_path).and_return("/motions/1")
    notification.stub(:eventable).and_return(stub(:motion))
    item.link.should == "/motions/1"
  end

  it "#avatar returns the correct user for the notification avatar" do
    item.avatar.should == item.actor
  end
end
