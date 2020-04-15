class Slack::PollSerializer < Slack::BaseSerializer
  private

  def first_attachment
    return super unless poll.active?
    super.merge(footer: I18n.t(:"slack.click_to_vote"))
  end

  def footer
    return unless poll.active?
    if poll.dates_as_options
      :click_to_vote_with_time_zone
    else
      :click_to_vote
    end
  end

  def additional_attachments
    return unless poll.active? && !poll.is_single_vote?
    poll.poll_options.map do |option|
      {
        color:      option.color,
        title:      option.display_name,
        title_link: slack_link_for(poll, poll_option_id: option.id, grant_membership: true)
      }
    end
  end

  def last_attachment
    return super unless poll.active? && poll.dates_as_options
    [{ text: I18n.t(:"slack.time_zone_message", zone: poll.time_zone) }]
  end

  def actions
    return unless poll.active? && poll.is_single_vote?
    poll.poll_options.map do |option|
      {
        name: option.name,
        text: option.display_name,
        type: :button
      }
    end
  end

  def text_options
    {
      poll_type:  I18n.t("poll_types.#{poll.poll_type}"),
      author:     object.user&.name,
      poll:       poll.title,
      discussion: poll.discussion&.title,
      group:      poll.group&.full_name
    }
  end

  def poll
    @poll ||= object.eventable.poll
  end

end
