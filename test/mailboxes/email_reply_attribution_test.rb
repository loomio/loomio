require "test_helper"

class EmailReplyAttributionTest < ActionMailbox::TestCase
  setup do
    @author = users(:admin)
    @member = users(:member)
    @comment = CommentService.create(
      comment: Comment.new(parent: discussions(:discussion), body: "Member's reply"),
      actor: @member
    )
  end

  test "reply to another member's comment is attributed to the notification recipient" do
    mail = NotificationMailer.topic_item(@author.id, @comment.created_topic_item.id).deliver_now
    assert_reply_attributed_to_recipient(mail)
  end

  test "notification delivery reply addresses belong to the recipient rather than the comment author" do
    notification = NotificationService.create!(
      kind: "comment_replied_to",
      subject: @comment.created_topic_item,
      actor: @member,
      recipient_user_ids: [ @author.id ]
    )
    NotificationDeliveryRouter.for(notification).route!
    delivery = notification.notification_deliveries.find_by!(channel: "email", recipient: @author)
    mail = NotificationMailer.notification(delivery.id).deliver_now
    assert_reply_attributed_to_recipient(mail)
  end

  private

  def assert_reply_attributed_to_recipient(mail)
    assert_equal [ @author.email ], mail.to
    assert_includes mail.reply_to.first, "u=#{@author.id}&k=#{@author.email_api_key}"
    refute_includes mail.reply_to.first, "u=#{@member.id}&k=#{@member.email_api_key}"

    assert_difference "Comment.count", 1 do
      receive_inbound_email_from_mail(
        from: @author.name_and_email,
        to: mail.reply_to,
        subject: "Re: #{mail.subject}",
        body: "Author's email reply"
      )
    end

    reply = Comment.order(:id).last
    assert_equal @author, reply.author
    assert_equal @author, reply.created_topic_item.actor
    assert_equal @comment, reply.parent
    assert_equal "Author's email reply", reply.body
    assert ReceivedEmail.last.released?
  end
end
