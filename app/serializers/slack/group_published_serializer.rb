class Slack::GroupPublishedSerializer < Slack::BaseSerializer
  def text
    I18n.t(:"slack.join_loomio_group", author: object.user.name)
  end
end
