# frozen_string_literal: true

class Views::ForwardMailer::CommentRejected < Views::ApplicationMailer::BaseLayout
  include PrettyUrlHelper

  def initialize(comment:)
    @comment = comment
  end

  def view_template
    p do
      plain t(:"forward_mailer.comment_rejected.reason",
        count: @comment.topic.comment_length_max)
    end

    p do
      plain t(:"forward_mailer.comment_rejected.recommendation")
    end

    p do
      link_to t(:"forward_mailer.comment_rejected.open_thread"),
        polymorphic_url(@comment.topic.topicable),
        class: "base-mailer__button base-mailer__button--accent"
    end
  end
end
