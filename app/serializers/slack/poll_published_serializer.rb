class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.tap do |att|
      if poll.dates_as_options
        att[:footer] = I18n.t(:"slack.time_zone_message", zone: poll.custom_fields['time_zone'])
        att[:ts]     = nil
      end
    end
  end

  def additional_attachments
    return unless !poll.is_single_vote?
    poll.poll_options.map do |option|
      {
        author_name: option.display_name,
        author_link: poll_url(poll, default_url_options.merge(poll_option_id: option.id))
      }
    end
  end

  def actions
    return unless poll.is_single_vote?
    poll.poll_options.map do |option|
      {
        name: option.name,
        text: option.display_name,
        type: :button
      }
    end
  end

  def poll
    @poll ||= object.eventable
  end

end
