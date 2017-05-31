class Slack::GroupInvitationSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.request_authorization_message", url: request_authorization_url)
  end

  private

  def request_authorization_url
    invitation_url(object.token, default_url_options.merge(
      back_to: scope.fetch(:back_to, group_url(group, default_url_options)),
      uid:     scope[:uid],
    ))
  end

  def group
    @group ||= object.group
  end
end
