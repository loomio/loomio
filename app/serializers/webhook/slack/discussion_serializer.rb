class Webhook::Slack::DiscussionSerializer < Webhook::Slack::BaseSerializer
  def text_options
    super.merge(discussion: model.title, group: model.group.full_name)
  end
end
