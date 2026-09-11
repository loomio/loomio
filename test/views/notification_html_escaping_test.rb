require "test_helper"

class NotificationHtmlEscapingTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    @recipient = users(:user)
    @topic_item = topic_items(:discussion_created_topic_item)
    @payload = "<img src=x onerror=alert(1)><script>alert(2)</script><b>A & B</b>"
    @actor.update!(name: @payload)
  end

  test "notification email escapes the actor name and preserves the title link" do
    component = Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: "new_discussion",
      with_title: true
    )

    document = render_fragment(component)
    heading = document.at_css(".email-notification-text")

    assert_empty heading.css("img, script, b")
    assert_includes heading.text, @payload
    assert heading.at_css("a")
  end

  test "notification email escapes a snapshotted actor name and preserves the title link" do
    component = Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: "new_discussion",
      translation_values: { name: @payload },
      with_title: true
    )

    document = render_fragment(component)
    heading = document.at_css(".email-notification-text")

    assert_empty heading.css("img, script, b")
    assert_includes heading.text, @payload
    assert heading.at_css("a")
  end

  test "notification email escapes an explicit plain-text title" do
    component = Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: "new_discussion",
      title: @payload,
      with_title: true
    )

    heading = render_fragment(component).at_css(".email-notification-text")

    assert_empty heading.css("img, script, b")
    assert_equal 2, heading.text.scan(@payload).length
  end

  test "notification email escapes other translation values" do
    component = Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: "reaction_created",
      translation_values: { reaction: @payload, model: "comment" },
      with_title: true
    )

    heading = render_fragment(component).at_css(".email-notification-text")

    assert_empty heading.css("img, script, b")
    assert_equal 2, heading.text.scan(@payload).length
    assert heading.at_css("a")
  end

  test "Matrix notification escapes the actor name and preserves the title link" do
    @topic_item.itemable.update_columns(title: @payload)
    component = Views::Chatbot::Matrix::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient
    )

    document = render_fragment(component)

    assert_empty document.css("img, script, b")
    assert_includes document.text, @payload
    assert_equal @payload, document.at_css("a").text
  end

  test "Matrix notification text escapes the actor name" do
    component = Views::Chatbot::Matrix::NotificationText.new(
      topic_item: @topic_item,
      recipient: @recipient
    )

    document = render_fragment(component)

    assert_empty document.css("img, script, b")
    assert_includes document.text, @payload
  end

  private

  def render_fragment(component)
    Nokogiri::HTML.fragment(ApplicationController.renderer.render(component, layout: false))
  end
end
