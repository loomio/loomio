require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
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
