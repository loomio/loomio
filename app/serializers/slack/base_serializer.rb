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
    model.group.community.channel
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
      title_link:  slack_link_for(model, invitation: true),
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
    (model.respond_to?(:body) && model.body)
  end

  def slack_text
    (model.respond_to?(:description) && model.description) ||
    (model.respond_to?(:details) && model.details) ||
    (model.respond_to?(:statement) && model.statement)
  end

  def slack_link_for(obj, opts = {})
    if opts[:invitation] && obj.group
      back_to = scope.fetch(:back_to, slack_link_for(obj, opts.except(:invitation)))
      invitation_url(invitation_token, link_options.merge(back_to: back_to))
    else
      polymorphic_url(obj, link_options.merge(opts))
    end
  end

  def invitation_token
    @invitation_token ||= model.group&.shareable_invitation&.token
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
