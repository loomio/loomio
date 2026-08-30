# frozen_string_literal: true

# Renders the notified record beneath its notification headline without pulling
# in the full standalone-mail layout, group banner, footer, or reply controls.
# Each model type is mapped explicitly so unsupported records remain headline-only.
class Views::UserMailer::Digest::NotificationContent < Views::ApplicationMailer::Component
  def initialize(notification:, recipient:)
    @recipient = recipient
    @itemable = notification.subject_model
  end

  def view_template
    return if @itemable.nil?
    return if @itemable.respond_to?(:discarded?) && @itemable.discarded?

    case normalized_itemable
    when Comment, Discussion
      render Views::NotificationMailer::Common::Body.new(itemable: normalized_itemable, recipient: @recipient)
    when Poll
      render Views::NotificationMailer::Poll::Summary.new(poll: normalized_itemable, recipient: @recipient)
    when Outcome
      render Views::NotificationMailer::Poll::Summary.new(poll: normalized_itemable.poll, recipient: @recipient)
    when Stance
      render Views::NotificationMailer::Poll::Stance.new(stance: normalized_itemable, recipient: @recipient)
    end
  end

  private

  def normalized_itemable
    @normalized_itemable ||= @itemable.is_a?(Topic) ? @itemable.topicable : @itemable
  end
end
