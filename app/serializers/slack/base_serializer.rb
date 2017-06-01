class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :icon_url, :channel, :attachments

  def text
    I18n.t(:"slack.#{object.kind}", text_options)
  end

  def username
    "Loomio Bot"
  end

  def icon_url
    User.helper_bot.avatar_url
  end

  def channel
    object.eventable.group.community.channel
  end

  def attachments
    [first_attachment, additional_attachments, last_attachment].flatten.compact.to_json
  end

  private

  def first_attachment
    {
      author_name: author.name,
      author_link: polymorphic_url(author, link_options),
      author_icon: author.avatar_url(:small),
      title:       slack_title,
      title_link:  model_url,
      text:        slack_text,
      callback_id: object.eventable_id,
      actions:     actions,
    }.compact
  end

  def last_attachment
    {
      ts: object.created_at.to_i,
      fields: [{
        value: "<#{model_url}|#{I18n.t(:"webhooks.slack.view_it_on_loomio")}>"
      }]
    }
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

  def slack_title(text = nil, params = {})
    (model.respond_to?(:name) && model.name) ||
    (model.respond_to?(:title) && model.title) ||
    (model.respond_to?(:body) && model.body)
  end

  def slack_text
    (model.respond_to?(:description) && model.description) ||
    (model.respond_to?(:details) && model.details) ||
    (model.respond_to?(:statement) && model.statement)
  end

  def model
    @model ||= object.eventable
  end

  def model_url
    polymorphic_url(model, link_options)
  end

  def author
    @author ||= object.user || model.author
  end

  def text_options
    { author: object.user.name }
  end

  def link_options
    default_url_options.merge(identifier: channel)
  end

end
