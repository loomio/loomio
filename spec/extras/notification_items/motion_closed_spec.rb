describe NotificationItems::MotionClosed do
  let(:notification) { stub(:notification) }
  let(:item) { NotificationItems::MotionClosed.new(notification) }

  it "#actor returns the user who closed the motion" do
    closer = stub(:user)
    notification.stub_chain(:event, :user).and_return(closer)
    item.actor.should == closer
  end

  context "user closed motion" do
    before { notification.stub_chain(:event, :user).and_return(stub(:user)) }

    it "#action_text returns a string" do
      item.action_text.should == I18n.t('notifications.motion_closed.by_user')
    end
    it "#avatar_url returns the users avatar url" do
      notification.stub_chain(:event, :user, :avatar_url).and_return("hello")
      item.avatar_url.should == notification.event.user.avatar_url
    end
    it "#avatar_initials returns the users avatar initials" do
      notification.stub_chain(:event, :user, :avatar_initials).and_return("hello")
      item.avatar_initials.should == notification.event.user.avatar_initials
    end
  end

  context "motion expired" do
    before { notification.stub_chain(:event, :user).and_return(nil) }

    it "#action_text returns a string" do
      item.action_text.should == I18n.t('notifications.motion_closed.by_expirey') + ": "
    end

    it "#avatar_url returns the users avatar url" do
      notification.stub_chain(:eventable, :author, :avatar_url).and_return("hello")
      item.avatar_url.should == notification.eventable.author.avatar_url
    end

    it "#avatar_initials returns the users avatar initials" do
      notification.stub_chain(:eventable, :author, :avatar_initials).and_return("hello")
      item.avatar_initials.should == notification.eventable.author.avatar_initials
    end
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
