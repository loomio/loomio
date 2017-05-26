class Slack::GroupInvitationSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.invite_to_loomio_group", {
      name: group.full_name,
      url: invitation_url(invitation_token, invitation_link_options)
    })
  end

  private

  def group
    @group ||= object.group
  end

  def community
    @community ||= group.community
  end

  def invitation_token
    group.invitations.shareable.first.token
  end

  def link_options
    default_url_options
  end

  def invitation_link_options
    default_url_options.merge(
      auth_as: :slack,
      back_to: poll_url(object, default_url_options),
      team: community.identity.custom_fields['slack_team_id']
    )
  end
end
