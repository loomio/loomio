class Slack::GroupIdentityCreatedSerializer < Slack::BaseSerializer
  private

  def text_options
    super.merge({
      url:   slack_link_for(model.group, invitation: true),
      group: model.group.full_name
    })
  end

  def include_attachments?
    false
  end
end
