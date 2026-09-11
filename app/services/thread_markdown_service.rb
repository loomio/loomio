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
    I18n.with_locale(user.locale) do
      [front_matter, title, topic_overview, activity].compact_blank.join("\n\n")
    end
  end

  private

  attr_reader :topic, :user

  # Stable front matter makes thread context easy to preserve in documents and
  # consume in other tools without mixing metadata into the visible hierarchy.
  def front_matter
    record = topic.topicable
    fields = {
      group: topic.group_id.present? ? topic.group.name : nil,
      created: timestamp(record.created_at),
      last_activity: timestamp(topic.last_activity_at),
      tags: Array(topic.tags).map { |tag| inline(tag) }.presence
    }.compact

    "---\n#{fields.map { |key, value| "#{key}: #{value.to_json}" }.join("\n")}\n---"
  end

  def title
    record = topic.topicable
    "# #{t(:thread_title, type: record.model_name.human, title: inline(record.title), author: author_name(record), timestamp: heading_timestamp(record.created_at))}"
  end

  def topic_overview
    case topic.topicable
    when Poll
      poll_markdown(topic.topicable, heading: "## #{t(:poll)}")
    else
      body(topic.topicable, heading_offset: 1)
    end
  end

  def activity
    content = topic_items.filter_map { |topic_item| event_markdown(topic_item) }
    content = ["_#{t(:no_activity)}._"] if content.empty?
    content.join("\n\n")
  end

  def topic_items
    topic.items.includes(:itemable, :user, parent: [:itemable, :user]).order(:sequence_id)
  end

  def event_markdown(topic_item)
    itemable = topic_item.itemable
    return if itemable == topic.topicable
    return if itemable.is_a?(Poll) && topic_item != itemable.created_topic_item
    return if itemable.respond_to?(:discarded?) && itemable.discarded?

    case itemable
    when Comment then comment_markdown(topic_item, itemable)
    when Poll
      poll_type = I18n.t("poll_types.#{itemable.poll_type}").sub(/\A./) { |character| character.upcase }
      heading = t(:poll_title, type: poll_type, title: inline(itemable.title), author: author_name(itemable), timestamp: heading_timestamp(topic_item.created_at))
      poll_markdown(itemable, heading: "## #{heading}")
    when Stance then stance_markdown(topic_item, itemable)
    when Outcome then outcome_markdown(topic_item, itemable)
    end
  end

  def comment_markdown(topic_item, comment)
    content = body(comment, heading_offset: 2)
    return if content.blank?

    parent_author = reply_author(topic_item)
    heading = if parent_author
      t(:comment_reply, author: author_name(comment), reply_author: parent_author, timestamp: heading_timestamp(topic_item.created_at))
    else
      t(:comment, author: author_name(comment), timestamp: heading_timestamp(topic_item.created_at))
    end
    sections = ["## #{heading}", content]
    sections << reactions_markdown(comment)
    sections.compact_blank.join("\n\n")
  end

  def poll_markdown(poll, heading:)
    metadata = []
    metadata << metadata_line(:status, poll_status(poll))
    metadata << metadata_line(:anonymous_voting, t(:yes)) if poll.anonymous?
    metadata << metadata_line(:options, poll.poll_options.map { |option| inline(option.name) }.join('; '))

    sections = [heading, metadata.join("\n")]
    sections << body(poll, heading_offset: heading[/\A#+/].length)
    sections << poll_results(poll)
    sections.compact_blank.join("\n\n")
  end

  def poll_status(poll)
    if poll.closed_at.present?
      t(:closed, value: timestamp(poll.closed_at))
    elsif poll.opening_at.present? && poll.opened_at.blank?
      t(:scheduled_to_open, value: timestamp(poll.opening_at))
    elsif poll.closing_at.present?
      t(:open_until, value: timestamp(poll.closing_at))
    else
      t(:open)
    end
  end

  def poll_results(poll)
    unless poll_results_visible?(poll)
      message = t(poll.hide_results == 'until_closed' ? :hidden_until_closed : :hidden_until_voted)
      return "### #{t(:current_results)}\n\n_#{message}._"
    end

    poll_results_table(poll)
  end

  def poll_results_table(poll)
    table = PollMarkdownResultsService.render(poll: poll, user: user)
    "### #{t(:current_results)}\n\n#{table}"
  end

  def stance_markdown(topic_item, stance)
    return unless stance_visible?(stance)

    reason = body(stance, heading_offset: 2)
    heading = t(:vote, response: stance_response_heading(stance), author: author_name(stance), timestamp: heading_timestamp(topic_item.created_at))
    sections = ["## #{heading}", reason]
    sections << reactions_markdown(stance)
    sections.compact_blank.join("\n\n")
  end

  def stance_visible?(stance)
    return false unless stance.latest? && stance.revoked_at.blank? && stance.cast_at.present?
    return false if stance.redacted_at.present?

    stance.participant_id == user.id || poll_results_visible?(stance.poll)
  end

  def stance_response_heading(stance)
    return t(:none_of_the_above) if stance.none_of_the_above?

    choices = stance.stance_choices.sort_by { |choice| choice.poll_option.priority }.map do |choice|
      name = inline(choice.poll_option.name)
      stance.poll.has_variable_score ? "#{name} #{choice.score}" : name
    end
    choices.presence&.join(', ') || t(:no_option_selected)
  end

  def outcome_markdown(topic_item, outcome)
    metadata = [
      outcome.review_on.present? && metadata_line(:review_date, outcome.review_on.iso8601)
    ].compact_blank.join("\n")
    content = body(outcome, heading_offset: 2)
    return if content.blank?

    heading = t(:outcome, author: author_name(outcome), timestamp: heading_timestamp(topic_item.created_at))
    ["## #{heading}", metadata, content].compact_blank.join("\n\n")
  end

  def poll_results_visible?(poll)
    return @poll_results_visible[poll.id] if @poll_results_visible.key?(poll.id)

    voted = poll.stances.latest.decided.exists?(participant_id: user.id)
    @poll_results_visible[poll.id] = poll.show_results?(voted: voted)
  end

  def reactions_markdown(record)
    reactions = record.reactions.includes(:user).group_by(&:reaction).map do |reaction, matching|
      names = matching.map { |item| author_name(item) }.sort.join(', ')
      "- #{inline(reaction)} #{names}"
    end
    reactions.any? && reactions.sort.join("\n")
  end

  def reply_author(topic_item)
    record = topic_item.parent&.itemable
    author_name(record) if record.is_a?(Comment) || record.is_a?(Poll) || record.is_a?(Stance) || record.is_a?(Outcome)
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

  def t(key, **options)
    I18n.t("thread_markdown.#{key}", **options)
  end

  def metadata_line(key, value)
    "- #{t(key, value: value)}"
  end

  def inline(value)
    value.to_s.squish
  end

  def heading_timestamp(value)
    value&.utc&.strftime("%Y-%m-%d %H:%M")
  end

  def timestamp(value)
    value&.utc&.iso8601
  end
end
