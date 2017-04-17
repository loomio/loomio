class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :icon_url, :channel, :attachments

  def text
    I18n.t text_translation_key, text_options
  end

  def username
    "Loomio Bot"
  end

  def icon_url
    User.helper_bot.avatar_url
  end

  def channel
    community.identifier
  end

  def attachments
    [{
      pretext:     object.custom_fields['message'],
      author_icon: object.user.avatar_url(:small),
      title:       slack_title,
      title_link:  model_url,
      text:        slack_text,
      ts:          object.created_at.to_i,
      fields: [{
        value: "<#{model_url}|#{I18n.t(:"webhooks.slack.view_it_on_loomio")}>"
      }]
    }.compact].to_json
  end

  private

  def text_translation_key
    if object.eventable.discussion
      :"webhooks.slack.#{object.kind}_with_discussion"
    else
      :"webhooks.slack.#{object.kind}"
    end
  end

  def community
    @community ||= Communities::Base.find(object.custom_fields['community_id'])
  end

  def slack_title(text = nil, params = {})
    (model.respond_to?(:name) && model.name) ||
    (model.respond_to?(:title) && model.title) ||
    (model.respond_to?(:body) && model.body)
  end

  def slack_text
    (model.respond_to?(:details) && model.details) ||
    (model.respond_to?(:statement) && model.statement)
  end

  def model
    @model || object.eventable
  end

  def author_url
    polymorphic_url(object.user, link_options)
  end

  def model_url
    polymorphic_url(model, link_options)
  end

  def text_options
    {
      author:     object.user.name,
      discussion: object.eventable.discussion&.title
    }
  end

  def link_options
    default_url_options.merge(identifier: community.identifier)
  end

end
