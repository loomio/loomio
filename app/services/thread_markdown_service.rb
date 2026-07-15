class ThreadMarkdownService
  def self.render(topic:, user:)
    new(topic, user).render
  end

  def initialize(topic, user)
    @topic = topic
    @user = user
    @poll_results_visible = {}
  end

  def render
    [title, thread_metadata, topic_overview, activity].compact_blank.join("\n\n")
  end

  private

  attr_reader :topic, :user

  def title
    "# #{inline(topic.topicable.title)}"
  end

  def thread_metadata
    record = topic.topicable
    lines = [
      "- **Thread type:** #{record.model_name.human}",
      topic.group&.name.present? && "- **Group:** #{inline(topic.group.name)}",
      "- **Started by:** #{author_name(record)}",
      "- **Created:** #{timestamp(record.created_at)}",
      topic.last_activity_at.present? && "- **Last activity:** #{timestamp(topic.last_activity_at)}",
      Array(topic.tags).any? && "- **Tags:** #{Array(topic.tags).map { |tag| inline(tag) }.join(', ')}"
    ]

    lines.compact_blank.join("\n")
  end

  def topic_overview
    case topic.topicable
    when Poll
      poll_markdown(topic.topicable, heading: "## Poll", include_author: false)
    else
      content = body(topic.topicable, heading_offset: 2)
      content.present? && "## Context\n\n#{content}"
    end
  end

  def activity
    content = events.filter_map { |event| event_markdown(event) }
    content = ["_No comments, polls, votes, or outcomes yet._"] if content.empty?
    "## Activity\n\n#{content.join("\n\n")}"
  end

  def events
    topic.items.includes(:eventable, :user, parent: [:eventable, :user]).order(:sequence_id)
  end

  def event_markdown(event)
    eventable = event.eventable
    return if eventable == topic.topicable
    return if eventable.respond_to?(:discarded?) && eventable.discarded?

    case eventable
    when Comment then comment_markdown(event, eventable)
    when Poll then poll_markdown(eventable, heading: "### Poll — #{inline(eventable.title)}", event: event)
    when Stance then stance_markdown(event, eventable)
    when Outcome then outcome_markdown(event, eventable)
    end
  end

  def comment_markdown(event, comment)
    content = body(comment, heading_offset: 3)
    return if content.blank?

    metadata = [
      "- **Posted:** #{timestamp(event.created_at)}",
      reply_to(event).present? && "- **In reply to:** #{reply_to(event)}"
    ].compact_blank.join("\n")

    "### Comment — #{author_name(comment)}\n\n#{metadata}\n\n#{content}"
  end

  def poll_markdown(poll, heading:, event: nil, include_author: true)
    metadata = []
    metadata << "- **Opened by:** #{author_name(poll)}" if include_author
    metadata << "- **Opened:** #{timestamp(event&.created_at || poll.opened_at || poll.created_at)}"
    metadata << "- **Type:** #{poll.poll_type.humanize}"
    metadata << "- **Status:** #{poll_status(poll)}"
    metadata << "- **Anonymous voting:** #{poll.anonymous? ? 'Yes' : 'No'}"
    metadata << "- **Options:** #{poll.poll_options.map { |option| inline(option.name) }.join('; ')}"

    sections = [heading, metadata.join("\n")]
    sections << body(poll, heading_offset: heading[/\A#+/].length)
    sections << poll_results(poll)
    sections.compact_blank.join("\n\n")
  end

  def poll_status(poll)
    if poll.closed_at.present?
      "Closed #{timestamp(poll.closed_at)}"
    elsif poll.opening_at.present? && poll.opened_at.blank?
      "Scheduled to open #{timestamp(poll.opening_at)}"
    elsif poll.closing_at.present?
      "Open; closes #{timestamp(poll.closing_at)}"
    else
      "Open"
    end
  end

  def poll_results(poll)
    unless poll_results_visible?(poll)
      visibility = poll.hide_results == 'until_closed' ? 'the poll closes' : 'the viewer votes'
      return "#### Current results\n\n_Hidden until #{visibility}._"
    end

    results = poll.poll_options.map do |option|
      result = "#{option.voter_count} #{'voter'.pluralize(option.voter_count)}"
      result += ", total score #{option.total_score}" if poll.has_variable_score
      "- **#{inline(option.name)}:** #{result}"
    end

    "#### Current results\n\n#{results.join("\n")}"
  end

  def stance_markdown(event, stance)
    return unless stance_visible?(stance)

    poll = stance.poll
    voter = poll.anonymous? ? "Anonymous participant" : author_name(stance)
    response = stance_response(stance)
    metadata = [
      "- **Submitted:** #{timestamp(event.created_at)}",
      "- **Response:** #{response}"
    ].join("\n")
    reason = body(stance, heading_offset: 3)
    sections = ["### Vote — #{voter} — #{inline(poll.title)}", metadata]
    sections << "#### Reason\n\n#{reason}" if reason.present?
    sections.join("\n\n")
  end

  def stance_visible?(stance)
    return false unless stance.latest? && stance.revoked_at.blank? && stance.cast_at.present?
    return false if stance.redacted_at.present?

    stance.participant_id == user.id || poll_results_visible?(stance.poll)
  end

  def stance_response(stance)
    return "None of the above" if stance.none_of_the_above?

    choices = stance.stance_choices.sort_by { |choice| choice.poll_option.priority }.map do |choice|
      name = inline(choice.poll_option.name)
      stance.poll.has_variable_score ? "#{name} (score: #{choice.score})" : name
    end
    choices.presence&.join('; ') || "No option selected"
  end

  def outcome_markdown(event, outcome)
    metadata = [
      "- **Announced by:** #{author_name(outcome)}",
      "- **Announced:** #{timestamp(event.created_at)}",
      "- **Status:** #{outcome.latest? ? 'Current' : 'Superseded'}",
      outcome.review_on.present? && "- **Review date:** #{outcome.review_on.iso8601}"
    ].compact_blank.join("\n")
    content = body(outcome, heading_offset: 3)
    return if content.blank?

    "### Outcome — #{inline(outcome.poll.title)}\n\n#{metadata}\n\n#{content}"
  end

  def poll_results_visible?(poll)
    return @poll_results_visible[poll.id] if @poll_results_visible.key?(poll.id)

    voted = poll.stances.latest.decided.exists?(participant_id: user.id)
    @poll_results_visible[poll.id] = poll.show_results?(voted: voted)
  end

  def reply_to(event)
    record = event.parent&.eventable
    case record
    when Comment then "comment by #{author_name(record)}"
    when Poll then "poll “#{inline(record.title)}”"
    when Stance
      voter = record.poll.anonymous? ? "anonymous participant" : author_name(record)
      "vote by #{voter} on “#{inline(record.poll.title)}”"
    when Outcome then "outcome for “#{inline(record.poll.title)}”"
    end
  end

  def author_name(record)
    author = if record.respond_to?(:author)
      record.author
    elsif record.respond_to?(:user)
      record.user
    end
    inline(author&.name.presence || I18n.t('common.anonymous'))
  end

  def body(record, heading_offset:)
    value = record.respond_to?(:body) ? record.body : nil
    format = record.respond_to?(:body_format) ? record.body_format : nil
    markdown = MarkdownService.render_markdown(value.to_s, format).strip.presence
    markdown&.gsub(/^(\#{1,6})(?=\s)/) do |heading|
      '#' * [heading.length + heading_offset, 6].min
    end
  end

  def inline(value)
    value.to_s.squish
  end

  def timestamp(value)
    value&.utc&.iso8601
  end
end
