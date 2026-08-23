# frozen_string_literal: true

class Views::Chatbot::Markdown::Notification < Views::Chatbot::Markdown::Base
  def initialize(topic_item:, poll: nil, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    url = polymorphic_url(@topic_item.itemable)
    message = @topic_item.recipient_message
    poll_type = @poll ? t("poll_types.#{@poll.poll_type}") : nil

    md t("notifications.with_title.#{@topic_item.kind}",
         actor: @topic_item.user.name,
         title: "[#{@topic_item.itemable.title_model.title}](#{url})",
         poll_type: poll_type,
         site_name: AppConfig.theme[:site_name])
    md "\n"

    if message.present?
      md "  #{MarkdownService.render_plain_text(message)}\n"
    end
  end
end
