class Slack::Ephemeral::StanceCreatedSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.stance_created", {
      title:      object.eventable.poll.title,
      position:   object.eventable.poll_options.first.display_name,
      stance_url: slack_link_for(object.eventable, invitation: true),
      poll_url:   slack_link_for(object.eventable.poll, invitation: true)
    })
  end
end
