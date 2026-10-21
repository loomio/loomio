# frozen_string_literal: true

class Views::ForwardMailer::CommentRejected < Views::ApplicationMailer::BaseLayout
  include PrettyUrlHelper

  def initialize(topic:, validation_messages:)
    @topic = topic
    @validation_messages = validation_messages
  end

  def view_template
    p do
      plain t(:"forward_mailer.comment_rejected.subject")
    end

    ul do
      @validation_messages.each { |message| li { plain message } }
    end

    p do
      plain t(:"forward_mailer.comment_rejected.recommendation")
    end

    p do
      link_to t(:"forward_mailer.comment_rejected.open_thread"),
        polymorphic_url(@topic.topicable),
        class: "email-button email-button-accent"
    end
  end
end
