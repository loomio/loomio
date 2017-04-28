class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.tap do |att|
      att[:footer] = I18n.t(:"slack.time_zone_message", zone: object.eventable.custom_fields['time_zone'])
      att[:ts]     = nil
    end
  end

  def actions
    object.eventable.poll_options.map do |option|
      {
        name: option.name,
        text: option.display_name,
        type: :button
      }
    end
  end

end
