class Slack::Ephemeral::StanceNotValidSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.stance_not_valid", poll: model.title, url: slack_link_for(object))
  end

  def model
    object
  end
end
