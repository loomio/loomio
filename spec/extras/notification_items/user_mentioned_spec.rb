require 'rails_helper'

describe NotificationItems::UserMentioned do
  let(:notification) { double(eventable: eventable) }
  let(:eventable) { double(:eventable) }
  let(:item) { NotificationItems::UserMentioned.new(notification) }

  it "#actor returns the user who mentioned someone" do
    mentioner = double(:user)
    eventable.stub(:user => mentioner)
    item.actor.should == notification.eventable.user
  end

  it "#action_text returns a string" do
    item.action_text.should == I18n.t('notifications.user_mentioned')
  end

  it "#title returns the discussion title" do
    eventable.stub(:discussion_title => "hello")
    item.title.should == notification.eventable.discussion_title
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    eventable.stub(:group_full_name => "goob")
    item.group_full_name.should == notification.eventable.group_full_name
  end

  it "#link returns a path to the comment" do
    item.stub_chain(:url_helpers, :discussion_path).and_return("/discussions/1/")
    eventable.stub(:id => "123", :discussion => double(:discussion))
    item.link.should == "/discussions/1/#comment-123"
  end
end
