require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "previously queued notifications cannot send mail to demo addresses" do
    recipient = users(:user)
    notification = Notification.create!(
      kind: "new_discussion",
      subject: topic_items(:discussion_created_topic_item),
      actor: users(:user)
    )
    delivery = NotificationDelivery.create!(notification: notification, recipient: recipient, channel: "email")
    recipient.update!(email: "alex@oatmilk.example")

    Rails.env.stub(:production?, true) do
      assert_no_emails do
        DeliverNotificationEmailWorker.perform_now(delivery.id)
        NotificationMailer.topic_item(recipient.id, notification.subject_id).deliver_now
      end
    end
    assert_nil delivery.reload.delivered_at
    assert_equal 'skipped', delivery.events.sole.kind
  end

  test 'a mention email links to the thread notification form' do
    item = topic_items(:discussion_created_topic_item)
    item.update_columns(kind: 'user_mentioned')

    mail = NotificationMailer.topic_item(users(:user).id, item.id)
    document = Nokogiri::HTML5(mail.html_part&.body&.decoded || mail.body.decoded)

    assert document.at_css('.email-footer a[href*="email_actions/unsubscribe"]')
    refute document.at_css('.email-footer a[href*="email_preferences"]')
  end

  test "saved markdown cannot put an unsafe URL in notification email HTML" do
    discussion = discussions(:discussion)
    discussion.update!(
      description: "[unsafe](javascript&#58;alert(1))",
      description_format: "md"
    )

    mail = NotificationMailer.topic_item(
      users(:user).id,
      topic_items(:discussion_created_topic_item).id
    )
    document = Nokogiri::HTML5(mail.html_part&.body&.decoded || mail.body.decoded)
    unsafe_link = document.at_css(".email-user-content a")

    assert unsafe_link
    assert_equal "#", unsafe_link["href"]
    refute document.css("[href], [src]").any? { |node|
      %w[href src].filter_map { |attribute| node[attribute] }.any? do |url|
        url.match?(/\A\s*(?:javascript|data):/i)
      end
    }
  end
end
