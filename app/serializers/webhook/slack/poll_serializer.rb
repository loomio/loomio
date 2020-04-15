class Webhook::Markdown::PollSerializer < Webhook::Slack::BaseSerializer
  private

  def text_options
    super.merge(poll_type: I18n.t("poll_types.#{object.eventable.poll.poll_type}"))
  end
end
