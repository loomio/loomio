class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :icon_url, :channel, :attachments

  def text
    object.custom_fields['message']
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
    [first_attachment, additional_attachments].flatten.to_json
  end

  private

  def first_attachment
    {
      author_name: object.user.name,
      author_link: user_url(object.user, default_url_options),
      author_icon: object.user.avatar_url(:small),
      title:       slack_title,
      title_link:  model_url,
      text:        slack_text,
      ts:          object.created_at.to_i,
      callback_id: object.eventable_id,
      fields: [{
        value: "<#{model_url}|#{I18n.t(:"webhooks.slack.view_it_on_loomio")}>"
      }],
      actions:     actions,
    }.compact
  end

  def additional_attachments
    # override to add additional attachments to the slack post
  end

  def actions
    []
  end

  def include_text?
    text.present?
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
