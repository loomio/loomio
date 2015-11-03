class Webhooks::Slack::NewDiscussion < Webhooks::Slack::Base

  def text
    I18n.t :"webhooks.slack.new_discussion", author: author.name, name: eventable.title, group: eventable.group.name
  end

  def attachment_title
    "<#{discussion_url(eventable)}|#{eventable.title}>"
  end

  def attachment_text
    "#{eventable.description}\n"
  end

  def attachment_fields
  end

  def attachment_fallback
  end

  def attachment_color
    SiteSettings.colors[:primary]
  end

end