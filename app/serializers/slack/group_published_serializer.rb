class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  def text
    I18n.t(:"slack.join_loomio_group", {
      author: group.creator.name,
      name: group.name,
      url: invitation_url(object.token, default_url_options.merge(identity_token: object.identity_token))
    })
  end

  private

  def group
    @group ||= model.group
  end
end
