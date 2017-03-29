class Slack::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attributes :text, :username, :attachments, :icon_url

  def text
    I18n.t :"webhooks.slack.#{object.kind}", text_options
  end

  def username
    "Loomio Bot"
  end

  def attachments
    [{
      title:       attachment_title,
      text:        attachment_text,
      fields:      attachment_fields,
      fallback:    attachment_fallback,
      color:       attachment_color
    }.compact].to_s
  end

  def icon_url
    User.helper_bot.avatar_url
  end

  private

  def text_options;        end
  def attachment_title;    end
  def attachment_text;     end
  def attachment_fallback; end
  def attachment_color;    end
  def attachment_fields
    [{ value: slack_link_for(model, I18n.t(:"webhooks.slack.view_it_on_loomio")) }]
  end

  def slack_link_for(model, text = nil, params = {})
    return unless model
    url  =   polymorphic_url(model, params.merge!(default_url_options))
    text ||= (model.respond_to?(:name) && model.name) ||
             (model.respond_to?(:title) && model.title) ||
             (model.respond_to?(:body) && model.body)
    "<#{url}|#{text}>"
  end

  def model
    @model || object.eventable
  end

end
