require 'test_helper'

class Events::CommentRepliedToTest < ActiveSupport::TestCase
  inline_jobs
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @discussion = discussions(:discussion)
    @discussion.add_guest!(@alien, @user)
    @parent = Comment.new(parent: @discussion, body: "Parent", author: @user)
    CommentService.create(comment: @parent, actor: @user)
    @comment = Comment.new(body: "Reply", parent: @parent, author: @alien)
    CommentService.create(comment: @comment, actor: @alien)
  end

  test "returns an event" do
    result = Events::CommentRepliedTo.publish!(@comment)
    assert_kind_of Event, result
  end

  test "creates a comment replied to event" do
    assert_difference -> { Event.where(kind: 'comment_replied_to').count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "emails the parent author" do
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "creates a notification" do
    assert_difference -> { Notification.count }, 1 do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end

  test "retrying the event does not repeat notification delivery" do
    event = nil
    publish_count = 0

    MessageChannelService.stub(:publish_models, ->(*) { publish_count += 1 }) do
      assert_difference -> { Notification.count }, 1 do
        assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
          event = Events::CommentRepliedTo.publish!(@comment)
          event.trigger!
        end
      end
    end

    notification = Notification.find_by!(event: event, user: @user)
    assert_equal "comment_replied_to", notification.kind
    assert_equal @comment, notification.subject
    assert_equal "event:#{event.id}", notification.deduplication_key
    assert_equal 1, publish_count
  end

  test "does not notify when comment and reply author are the same" do
    @parent.update!(author: @comment.author)
    assert_no_difference -> { Notification.count } do
      Events::CommentRepliedTo.publish!(@comment)
    end
  end
end
