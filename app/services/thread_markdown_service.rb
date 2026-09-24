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
    items = topic_items.to_a
    preload_itemables(items)
    @poll_created_item_ids = poll_created_item_ids(items)
    anchored_poll_ids = items.filter_map { |topic_item| topic_item.itemable.id if poll_anchor?(topic_item) }.to_set
    poll_items = poll_items_by_poll(items, anchored_poll_ids)
    poll_item_ids = poll_items.values.flatten.to_set(&:id)

    content = items.filter_map do |topic_item|
      next if poll_item_ids.include?(topic_item.id)

      event = event_markdown(topic_item)
      poll = topic_item.itemable
      next event unless poll.is_a?(Poll) && anchored_poll_ids.include?(poll.id)

      [event, poll_comments_markdown(poll_items.fetch(poll.id, []))].compact_blank.join("\n\n")
    end
    content = ["_#{t(:no_activity)}._"] if content.empty?
    content.join("\n\n")
  end

  def preload_itemables(items)
    itemables = items.map(&:itemable)
    ActiveRecord::Associations::Preloader.new(records: itemables.grep(Comment), associations: [:user, :parent, {reactions: :user}]).call
    ActiveRecord::Associations::Preloader.new(records: itemables.grep(Stance), associations: [:participant, :poll, {reactions: :user}]).call
  end

  # The same rule as HasTopicItems#created_topic_item, read from the loaded
  # items instead of queried per poll.
  def poll_created_item_ids(items)
    items
      .select { |topic_item| topic_item.itemable.is_a?(Poll) && topic_item.kind == topic_item.itemable.created_topic_item_kind.to_s }
      .group_by(&:itemable_id)
      .transform_values { |created_items| created_items.min_by(&:id).id }
  end

  def poll_anchor?(topic_item)
    poll = topic_item.itemable
    poll.is_a?(Poll) && poll != topic.topicable && !poll.discarded? && topic_item.id == @poll_created_item_ids[poll.id]
  end

  # Groups each vote and poll reply item under the anchored poll that owns it.
  def poll_items_by_poll(items, anchored_poll_ids)
    poll_ids_by_record = {}

    items.each_with_object(Hash.new { |hash, poll_id| hash[poll_id] = [] }) do |topic_item, poll_items|
      poll_id = owning_poll_id(topic_item.itemable, poll_ids_by_record)
      next if poll_id.nil?

      poll_ids_by_record[node_key(topic_item.itemable)] = poll_id
      poll_items[poll_id] << topic_item if anchored_poll_ids.include?(poll_id)
    end
  end

  def owning_poll_id(itemable, poll_ids_by_record)
    case itemable
    when Stance then itemable.poll_id
    when Comment
      parent = itemable.parent
      case parent
      when Poll then parent.id
      when Stance then parent.poll_id
      when Comment then poll_ids_by_record[node_key(parent)]
      end
    end
  end

  # Compacts the poll's votes (stances) and the comments/replies on them into a
  # single "Comments" block beneath the poll's results.
  def poll_comments_markdown(items)
    nodes = items.filter_map { |topic_item| poll_comment_node(topic_item) }
    return if nodes.empty?

    keys = nodes.to_set { |node| node[:key] }
    roots, replies = nodes.partition { |node| !keys.include?(node[:parent_key]) }
    children = replies.group_by { |node| node[:parent_key] }
    entries = roots.flat_map { |root| comment_entries(root, children, 0) }

    "### #{t(:comments)}\n\n#{entries.join("\n\n")}"
  end

  def node_key(itemable)
    [itemable.class.name, itemable.id]
  end

  def poll_comment_node(topic_item)
    itemable = topic_item.itemable
    return if itemable.discarded?
    return if itemable.is_a?(Stance) && !stance_visible?(itemable)

    content = body(itemable, heading_offset: 3)
    return if content.blank?

    parent = itemable.parent if itemable.is_a?(Comment) && !itemable.parent.is_a?(Poll)

    {topic_item: topic_item, itemable: itemable, key: node_key(itemable), parent: parent, parent_key: parent && node_key(parent), content: content}
  end

  # Depth is capped at two nested levels.
  def comment_entries(node, children, depth)
    replies = children.fetch(node[:key], []).flat_map { |child| comment_entries(child, children, [depth + 1, 2].min) }
    [comment_entry(node, depth), *replies]
  end

  def comment_entry(node, depth)
    itemable = node[:itemable]
    details = [heading_timestamp(node[:topic_item].created_at)]
    details << reply_context(node[:parent]) if depth.zero? && node[:parent]
    header = "**#{author_name(itemable)}** (#{details.join(', ')}):"
    # indent replies to comments for a better visualization
    header = "&nbsp;&nbsp;&nbsp;&nbsp;" * depth + " ↳ " + header unless depth.zero?
    reactions = compact_reactions(itemable)
    content = node[:content]

    if inline_content?(content)
      entry = "#{header} #{content}"
      reactions ? "#{entry} (Reactions: #{reactions})" : entry
    else
      content = "#{content}\n\nReactions: #{reactions}" if reactions
      content = blockquote(content, depth) unless depth.zero?
      "#{header}\n\n#{content}"
    end
  end

  def reply_context(parent)
    return t(:in_reply_to_hidden_vote) if parent.is_a?(Stance) && !stance_visible?(parent)

    t(:in_reply_to, author: author_name(parent))
  end

  # Plain text only when Markdown renders it as a single paragraph.
  def inline_content?(content)
    return false if content.include?("\n")

    blocks = Nokogiri::HTML.fragment(MarkdownService.render_html(content)).element_children
    blocks.one? && blocks.first.name == 'p'
  end

  def blockquote(content, level)
    prefix = Array.new(level, '>').join(' ')
    content.split("\n", -1).map { |line| line.empty? ? prefix : "#{prefix} #{line}" }.join("\n")
  end

  def compact_reactions(record)
    reaction_names(record).map { |reaction, names| "#{names.length} #{reaction} (#{names.join(', ')})" }.join(', ').presence
  end

  def topic_items
    topic.items.includes(:itemable, :user, parent: [:itemable, :user]).order(:sequence_id)
  end

  def event_markdown(topic_item)
    itemable = topic_item.itemable
    return if itemable == topic.topicable
    return if itemable.is_a?(Poll) && topic_item.id != @poll_created_item_ids[itemable.id]
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
    @poll_results_visible[poll.id] = poll.results_visible?(voted: voted)
  end

  def reactions_markdown(record)
    lines = reaction_names(record).map { |reaction, names| "- #{reaction} #{names.join(', ')}" }
    lines.any? && lines.join("\n")
  end

  # Reactions grouped by emoji, each with the sorted names of who reacted.
  def reaction_names(record)
    record.reactions.group_by(&:reaction).map do |reaction, matching|
      [inline(reaction), matching.map { |item| author_name(item) }.sort]
    end.sort
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
