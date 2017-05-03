class Slack::StanceCreatedSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.stance_created", {
      title:      object.eventable.poll.title,
      position:   object.eventable.poll_options.first.display_name,
      poll_url:   polymorphic_url(object.eventable.poll, default_url_options),
      stance_url: polymorphic_url(object.eventable, default_url_options)
    })
  end
end
