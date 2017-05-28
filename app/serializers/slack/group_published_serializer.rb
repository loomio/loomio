class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  def text
    I18n.t(:"slack.join_loomio_group", {
      author: model.creator.name,
      name: model.name,
      url: invitation_url(model.shareable_invitation.token, default_url_options)
    })
  end
end
