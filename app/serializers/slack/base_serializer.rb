class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :icon_url, :channel, :attachments

  def text
    I18n.t(:"slack.#{object.kind}", text_options)
  end

  def username
    "#{AppConfig.theme[:site_name]} Bot"
  end

  def icon_url
    User.helper_bot.avatar_url
  end

  def channel
    model.group.slack_channel_name
  end

  def attachments
    [first_attachment, additional_attachments, last_attachment].flatten.compact.to_json
  end

  private

  def first_attachment
    {
      author_name: author.name,
      author_link: slack_link_for(author),
      author_icon: author.avatar_url(:small),
      title:       slack_title,
      title_link:  slack_link_for(model, grant_membership: true),
      text:        slack_text,
      callback_id: model.id,
      actions:     actions
    }.compact
  end

  def additional_attachments
    # override to add additional attachments to the slack post
  end

  def last_attachment
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
    (model.respond_to?(:body) && ensure_markdown(model, 'body'))
  end

  def slack_text
    (model.respond_to?(:description) && ensure_markdown(model, 'description')) ||
    (model.respond_to?(:details) && ensure_markdown(model, 'details')) ||
    (model.respond_to?(:statement) && ensure_markdown(model, 'statement'))
  end

  def ensure_markdown(model, attribute)
    format_method_name = "#{attribute}_format"
    if model.respond_to?(format_method_name.to_sym) && model.public_send(format_method_name) == 'html'
      ReverseMarkdown.convert(model.public_send(attribute))
    else
      model.public_send(attribute)
    end
  end

  def slack_link_for(obj, opts = {})
    if opts[:grant_membership] && obj.group.presence
      back_to = scope.fetch(:back_to, slack_link_for(obj, opts.except(:grant_membership)))
      join_url(obj.group, link_options.merge(back_to: back_to))
    else
      polymorphic_url(obj, link_options.merge(opts))
    end
  end

  def model
    @model ||= object.eventable
  end

  def author
    @author ||= object.user || model.author
  end

  def text_options
    { author: object.user.name }
  end

  def link_options
    default_url_options.merge(identifier: channel, uid: scope[:uid]).compact
  end

  def scope
    Hash(super)
  end

end
