class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :attachments, :icon_url, :channel

  def text
    I18n.t :"webhooks.slack.#{object.kind}", text_options
  end

  def username
    "Loomio Bot"
  end

  def attachments
    [first_attachment].to_s
  end

  def icon_url
    User.helper_bot.avatar_url
  end

  def channel
    community.identifier
  end

  private

  def first_attachment
    {fields: Array(slack_link_for(model, I18n.t(:"webhooks.slack.view_it_on_loomio")))}
  end

  def community
    @community ||= Communities::Base.find(object.custom_fields['community_id'])
  end

  def slack_link_for(model, text = nil, params = {})
    return unless model
    url  =   polymorphic_url(model, params.merge!(link_options))
    text ||= (model.respond_to?(:name) && model.name) ||
             (model.respond_to?(:title) && model.title) ||
             (model.respond_to?(:body) && model.body)
    "<#{url}|#{text}>"
  end

  def model
    @model || object.eventable
  end

  def text_options
    {}
  end

  def link_options
    default_url_options.merge(identifier: community.identifier)
  end

end
