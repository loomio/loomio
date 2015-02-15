require 'rails_helper'

describe NotificationItems::NewDiscussion do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::NewDiscussion.new(notification) }

  it "#actor returns the user who created a discussion" do
    actor = double(:actor)
    notification.stub_chain(:eventable, :author).and_return(actor)
    expect(item.actor).to eq notification.eventable.author
  end

  it "#action_text returns a string" do
    expect(item.action_text).to eq I18n.t('notifications.new_discussion')
  end

  it "#title returns the motion name" do
    notification.stub_chain(:eventable, :title).and_return("hello")
    expect(item.title).to eq notification.eventable.title
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    expect(item.group_full_name).to eq notification.eventable.group_full_name
  end

  it "#link returns a path to the motion's discussion" do
    item.stub_chain(:url_helpers, :discussion_path).and_return("/discussions/1")
    notification.stub_chain(:eventable).and_return(double(:discussion))
    expect(item.link).to eq "/discussions/1"
  end
end
