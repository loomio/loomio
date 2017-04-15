class Slack::PollPublishedSerializer < Slack::BaseSerializer
  private

  def first_attachment
    super.tap do |json|
      json.merge(
        title: "Message:",
        text: object.custom_fields['message']
      ) if object.custom_fields['message']
    end
  end

end
