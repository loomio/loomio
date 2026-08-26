# frozen_string_literal: true

class Views::Chatbot::Matrix::NotificationText < Views::Chatbot::Base
  def initialize(topic_item:, poll: nil, recipient: nil)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    url = polymorphic_url(@topic_item.itemable)
    message = @topic_item.recipient_message if @topic_item.is_a?(NotificationRenderingContext)
    title = capture { link_to(TranslationService.plain_text(@topic_item.itemable.title_model, :title, @recipient), url) }
    poll_type = @poll ? t("poll_types.#{@poll.poll_type}") : nil

    p { raw t("notifications.without_title.#{@topic_item.kind}", actor: @topic_item.user.name, title: title, poll_type: poll_type, site_name: AppConfig.theme[:site_name]).html_safe }

    if message.present?
      i { raw MarkdownService.render_plain_text(message) }
    end
  end
end
