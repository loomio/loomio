class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def actions
    object.eventable.poll_options.map do |option|
      {
        name: option.name,
        text: option.name.humanize,
        type: :button
      }
    end
  end

end
