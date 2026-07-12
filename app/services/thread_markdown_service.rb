class ThreadMarkdownService
  def self.render(topic:, user:)
    new(topic, user).render
  end

  def initialize(topic, user)
    @topic = topic
    @user = user
  end

  def render
    ["# #{topic.topicable.title}", body(topic.topicable), *items].compact_blank.join("\n\n")
  end

  private

  attr_reader :topic, :user

  def items
    topic.items.includes(:eventable, :user).order(:sequence_id).filter_map do |event|
      event_markdown(event)
    end
  end

  def event_markdown(event)
    eventable = event.eventable
    return if eventable.respond_to?(:discarded?) && eventable.discarded?

    label = "## #{event.user&.name || I18n.t('common.anonymous')} — #{event.kind.humanize}"
    content = case eventable
    when Comment then body(eventable)
    when Poll then ["### #{eventable.title}", body(eventable)].compact_blank.join("\n\n")
    when Stance then stance(eventable)
    when Outcome then body(eventable)
    end
    return if content.blank?

    "#{label}\n\n#{content}"
  end

  def stance(stance)
    return unless stance.participant_id == user.id || stance.poll.show_results?(voted: true)

    choices = stance.poll_options.map(&:name).join(', ')
    reason = body(stance)
    [choices.presence && "Vote: #{choices}", reason].compact_blank.join("\n\n")
  end

  def body(record)
    value = record.respond_to?(:body) ? record.body : nil
    format = record.respond_to?(:body_format) ? record.body_format : nil
    MarkdownService.render_markdown(value.to_s, format).strip.presence
  end
end
