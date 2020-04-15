class Slack::DiscussionSerializer < Slack::BaseSerializer
  def text_options
    super.merge(discussion: model.title, group: model.group.full_name)
  end
end
