class Slack::GroupInvitationSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.invite_to_loomio_group", {
      name: group.full_name,
      url: invitation_url(object.token, default_url_options.merge(
        back_to: scope.fetch(:back_to, group_url(group, default_url_options)),
        uid:     scope[:uid],
      ))
    })
  end

  private

  def group
    @group ||= object.group
  end
end
