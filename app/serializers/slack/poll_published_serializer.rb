class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.tap do |att|
      if object.eventable.dates_as_options
        att[:footer] = I18n.t(:"slack.time_zone_message", zone: object.eventable.custom_fields['time_zone'])
        att[:ts]     = nil
      end
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
