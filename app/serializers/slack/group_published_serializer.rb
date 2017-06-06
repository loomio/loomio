class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  private

  def include_attachments?
    false
  end
end
