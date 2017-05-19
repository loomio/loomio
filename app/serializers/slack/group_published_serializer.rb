class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  def text
    I18n.t(:"slack.join_loomio_group", {
      author: object.user.name,
      name: model.name,
      url: invitation_url(invitation_token, invitation_link_options)
    })
  end


  def channel
    object.custom_fields['identifier']
  end

  private

  def invitation_token
    object.custom_fields['invitation_token']
  end

  def link_options
    default_url_options
  end

  def invitation_link_options
    default_url_options.merge(auth_as: :slack, team: model.community.identity.custom_fields['slack_team_id'])
  end
end
