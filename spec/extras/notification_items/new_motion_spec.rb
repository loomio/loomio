require 'rails_helper'

describe NotificationItems::NewMotion do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::NewMotion.new(notification) }

  it "#actor returns the user who created a motion" do
    actor = double(:actor)
    notification.stub_chain(:eventable, :author).and_return(actor)
    item.actor.should == notification.eventable.author
  end

  it "#action_text returns a string" do
    item.action_text.should == I18n.t('notifications.new_motion') + ": "
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :name).and_return("hello")
    item.title.should == notification.eventable.name
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    item.group_full_name.should == notification.eventable.group_full_name
  end

  it "#link returns a path to the motion's discussion" do
    item.stub_chain(:url_helpers, :discussion_path).and_return("/discussions/1")
    notification.stub_chain(:eventable, :discussion).and_return(double(:discussion))
    item.link.should == "/discussions/1"
  end
end
