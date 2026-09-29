class ThreadMarkdownService
  def self.render(topic:, user:)
    new(topic, user).render
  end

  # People invited by email may not have set a name yet, so fall back to their
  # username rather than leaving a blank that breaks sorting and reads as
  # missing. User#name already labels deleted accounts.
  def self.person_name(user)
    user&.name.presence || user&.username.presence || I18n.t('common.anonymous')
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
      key: record.key,
      group: topic.group_id.present? ? topic.group.name : nil,
      created: timestamp(record.created_at),
      last_activity: timestamp(topic.last_activity_at),
      tags: Array(topic.tags).map { |tag| inline(tag) }.presence
    }.compact

    "---\n#{fields.map { |key, value| "#{key}: #{value.to_json}" }.join("\n")}\n---"
  end

  def title
    record = topic.topicable
    "# #{[titled(record.model_name.human, record.title), author_name(record), heading_timestamp(record.created_at)].join(' · ')}"
  end

  def topic_overview
    case topic.topicable
    when Poll
      poll_markdown(topic.topicable, heading: "## #{t(:poll)}")
    else
      body(topic.topicable, heading_offset: 1)
    end
  end

  # Renders the thread in the same tree the app shows: items sorted by
  # position_key, nested by depth. Polls are "##" sections. Comments, votes,
  # and outcomes are blockquotes, nested one level per reply, so each person's
  # text has a clear boundary and Markdown parsers read the replies as a tree.
  # Items beneath a poll start one level in, under its heading.
  def activity
    items = activity_items
    return "_#{t(:no_activity)}._" if items.empty?

    in_poll_section = false
    items.each_with_index.flat_map do |item, index|
      in_poll_section = poll_section?(item) if item.depth <= 1
      level = poll_section?(item) ? 0 : item.depth - (in_poll_section ? 1 : 0)
      # A reply continues its parent's blockquote, so the line before it
      # carries the parent's quote prefix.
      separator = quote_prefix([level - 1, 0].max) unless index.zero?
      [separator, quote(item_markdown(item), level)].compact
    end.join("\n")
  end

  def activity_items
    items = topic.items
      .where(kind: %w[new_comment poll_created stance_created stance_updated outcome_created])
      .where.not(position_key: nil)
      .includes(:itemable)
      .order(:position_key)
      .to_a
    items.reject! { |item| item.itemable.nil? || item.itemable == topic.topicable }
    items.select! { |item| !item.itemable.is_a?(Poll) || item.id == item.itemable.created_topic_item&.id }
    preload(items)
    items
  end

  def preload(items)
    itemables = items.map(&:itemable)
    ActiveRecord::Associations::Preloader.new(records: itemables.grep(Comment), associations: [:user, :parent, {reactions: :user}]).call
    ActiveRecord::Associations::Preloader.new(records: itemables.grep(Stance), associations: [:participant, {poll: :poll_options}, {stance_choices: :poll_option}, {reactions: :user}]).call
    ActiveRecord::Associations::Preloader.new(records: itemables.grep(Outcome), associations: [:author, {reactions: :user}]).call
  end

  def poll_section?(item)
    item.itemable.is_a?(Poll) && !item.itemable.discarded?
  end

  def quote_prefix(level)
    Array.new(level, '>').join(' ')
  end

  def quote(markdown, level)
    return markdown if level.zero?

    prefix = quote_prefix(level)
    markdown.split("\n", -1).map { |line| line.empty? ? prefix : "#{prefix} #{line}" }.join("\n")
  end

  def item_markdown(item)
    itemable = item.itemable
    return item_header(item, "_#{t(:removed)}_") if itemable.discarded?

    case itemable
    when Poll
      poll_type = I18n.t("poll_types.#{itemable.poll_type}").sub(/\A./) { |character| character.upcase }
      heading = [titled(poll_type, itemable.title), author_name(itemable), heading_timestamp(item.created_at), "##{item.sequence_id}"].join(' · ')
      poll_markdown(itemable, heading: "## #{heading}")
    when Comment
      [item_header(item, author_label(itemable)), body(itemable, heading_offset: 2)].compact_blank.join("\n\n")
    when Stance
      stance_markdown(item, itemable)
    when Outcome
      metadata = itemable.review_on.present? && metadata_line(:review_date, itemable.review_on.iso8601)
      [item_header(item, t(:shared_outcome, author: author_label(itemable))), metadata, body(itemable, heading_offset: 2)].compact_blank.join("\n\n")
    end
  end

  # Mirrors the thread's vote item: the voter and time are always shown, the
  # choice and reason only when the reader can see the poll's results.
  def stance_markdown(item, stance)
    author = author_label(stance)
    return item_header(item, t(:vote_removed, author: author)) if stance.revoked_at.present?
    return item_header(item, t(:undecided, author: author)) if stance.cast_at.blank?
    return item_header(item, t(:voted_hidden, author: author)) unless poll_results_visible?(stance.poll)

    summary = t(:voted, author: author, response: "**#{stance_response_heading(stance)}**")
    summary += " (#{t(:superseded)})" unless stance.latest?
    reason = body(stance, heading_offset: 2) unless stance.redacted_at.present?
    [item_header(item, summary), reason].compact_blank.join("\n\n")
  end

  def author_label(record)
    "**#{author_name(record)}**"
  end

  # One line per item: who (and for votes and outcomes, what), when, its
  # sequence id (which with the thread key identifies the item in the app),
  # and who reacted.
  def item_header(item, summary)
    parts = [summary, heading_timestamp(item.created_at), "##{item.sequence_id}"]
    parts.concat(reaction_names(item.itemable).map { |reaction, names| "#{reaction} #{names.join(', ')}" })
    parts.join(' · ')
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

  def stance_response_heading(stance)
    return t(:none_of_the_above) if stance.none_of_the_above?

    choices = stance.stance_choices.sort_by { |choice| choice.poll_option.priority }.map do |choice|
      name = inline(choice.poll_option.name)
      stance.poll.has_variable_score ? "#{name} #{choice.score}" : name
    end
    choices.presence&.join(', ') || t(:no_option_selected)
  end

  def poll_results_visible?(poll)
    return @poll_results_visible[poll.id] if @poll_results_visible.key?(poll.id)

    voted = poll.stances.latest.decided.exists?(participant_id: user.id)
    @poll_results_visible[poll.id] = poll.results_visible?(voted: voted)
  end

  # Reactions grouped by emoji, each with the sorted names of who reacted.
  def reaction_names(record)
    return [] unless record.respond_to?(:reactions)

    record.reactions.group_by(&:reaction).map do |reaction, matching|
      [inline(reaction), matching.map { |item| author_name(item) }.sort]
    end.sort
  end

  def author_name(record)
    author = if record.respond_to?(:author)
      record.author
    elsif record.respond_to?(:user)
      record.user
    end
    inline(self.class.person_name(author))
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

  def titled(type, title)
    "#{type}: #{inline(title)}"
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
