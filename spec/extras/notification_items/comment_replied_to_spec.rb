require 'rails_helper'

describe NotificationItems::CommentRepliedTo do
  let(:notification) { double(:notification) }
  let(:item) { NotificationItems::CommentRepliedTo.new(notification) }

  it "#actor returns the user who posted the comment" do
    poster = double(:user)
    notification.stub_chain(:eventable, :user).and_return(poster)
    expect(item.actor).to eq notification.eventable.user
  end

  it "#action_text returns a string" do
    expect(item.action_text).to eq I18n.t('notifications.comment_replied_to')
  end

  it "#title returns the discussion title" do
    notification.stub_chain(:eventable, :discussion_title).and_return("hello")
    expect(item.title).to eq notification.eventable.discussion_title
  end

  it "#group_full_name returns the discussion's group name including a parent if there is one" do
    notification.stub_chain(:eventable, :group_full_name).and_return("goob")
    expect(item.group_full_name).to eq notification.eventable.group_full_name
  end

  it "#link returns a path to the discussion" do
    item.stub_chain(:url_helpers, :discussion_path).and_return("/discussions/1")
    notification.stub_chain(:eventable, :comment_id).and_return(1)
    notification.stub_chain(:eventable, :discussion).and_return(stub:(:discussion))
    expect(item.link).to eq "/discussions/1#comment-1"
  end
end
