class Webhook::Notion::EventSerializer < ActiveModel::Serializer
  include PrettyUrlHelper

  # Returns Notion page properties hash for creating/updating a database row
  attributes :properties, :description

  def properties
    props = {
      "Title" => title_property,
      "Event" => select_property(event_label),
      "Author" => rich_text_property(user.name),
      "URL" => url_property(event_url),
      "Group" => rich_text_property(object.eventable.group.full_name)
    }

    if poll
      props["Type"] = select_property(poll.poll_type.titleize)
      props["Status"] = select_property(poll_status)
      props["Closing"] = date_property(poll.closing_at) if poll.closing_at
    end

    props
  end

  def description
    body = object.eventable.respond_to?(:body) ? object.eventable.body : nil
    body.present? ? body.truncate(2000) : nil
  end

  private

  def poll
    @poll ||= if %w[Poll Stance Outcome].include?(object.eventable_type)
      object.eventable.poll
    end
  end

  def user
    object.user || object.eventable.author
  end

  def event_url
    polymorphic_url(object.eventable)
  end

  def event_label
    I18n.t("notifications.without_title.#{object.kind}",
           actor: user.name,
           title: object.eventable.title_model.title,
           poll_type: poll ? I18n.t("poll_types.#{poll.poll_type}") : nil,
           site_name: AppConfig.theme[:site_name])
        .gsub(/\[|\]/, '')
        .gsub(/\(http[^\)]*\)/, '')
        .strip
        .truncate(100)
  end

  def poll_status
    if poll.closed?
      "Closed"
    elsif poll.active?
      "Open"
    elsif poll.scheduled?
      "Scheduled"
    else
      "Draft"
    end
  end

  def title_property
    { title: [{ text: { content: object.eventable.title_model.title.truncate(100) } }] }
  end

  def select_property(value)
    { select: { name: value.truncate(100) } }
  end

  def rich_text_property(value)
    { rich_text: [{ text: { content: value.to_s.truncate(2000) } }] }
  end

  def url_property(value)
    { url: value }
  end

  def date_property(value)
    { date: { start: value.iso8601 } }
  end
end
