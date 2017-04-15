class Slack::OutcomePublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.merge(
      title: "Outcome:",
      text: object.eventable.statement
    )
  end

end
