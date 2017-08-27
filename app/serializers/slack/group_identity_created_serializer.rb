class Slack::GroupIdentityCreatedSerializer < Slack::BaseSerializer
  private

  def include_attachments?
    false
  end
end
