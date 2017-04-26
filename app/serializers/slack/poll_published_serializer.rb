class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.merge(actions: object.eventable.poll_options.map do |option|
      {
        name: option.name,
        text: option.name.humanize,
        type: :button,
        value: option.name
      }
    end)
  end

end
