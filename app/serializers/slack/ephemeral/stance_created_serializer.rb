class Slack::Ephemeral::StanceCreatedSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.stance_created", {
      title:      model.poll.title,
      position:   model.poll_options.first.display_name,
      stance_url: slack_link_for(model, grant_membership: true),
      poll_url:   slack_link_for(model.poll, grant_membership: true)
    })
  end
end
