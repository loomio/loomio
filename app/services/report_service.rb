class ReportService
  VALID_INTERVALS = %w[year month week day].freeze

  def initialize(interval: 'month', group_ids: nil, all_groups: false, start_at: 6.months.ago, end_at: 1.minute.ago)
    raise ArgumentError, "invalid interval value: #{interval}" unless VALID_INTERVALS.include?(interval)
    @interval = interval
    @all_groups = all_groups
    @group_ids = group_ids
    @start_at = start_at
    @end_at = end_at
    @direct_threads = all_groups || Array(@group_ids).include?(0)
  end

  # WHERE clause fragment scoping topics to the requested groups.
  # When all_groups is true we skip the massive IN list entirely.
  def topic_group_filter(col: 'topics.group_id')
    if @all_groups
      @direct_threads ? "1=1" : "#{col} IS NOT NULL"
    else
      "(#{col} IN (#{@group_ids.join(',')}) #{@direct_threads ? "OR #{col} IS NULL" : ''})"
    end
  end

  def intervals
    vals = []
    case @interval
    when 'year'
      next_val = @start_at.to_date.at_beginning_of_year
    when 'month'
      next_val = @start_at.to_date.at_beginning_of_month
    when 'week'
      next_val = @start_at.to_date.at_beginning_of_week
    when 'day'
      next_val = @start_at.to_date
    else
      raise "invalid interval value: #{@interval}"
    end

    while next_val < @end_at
      vals.push(next_val)
      next_val = (next_val + 1.send(@interval)).to_date
    end
    vals
  end

  def rows_to_hash(results, name_a = 'interval', name_b = 'count')
    results.to_a.map {|row| [row[name_a], row[name_b]]}.to_h
  end

  def memberships_per_interval
    group_filter = @all_groups ? "1=1" : "group_id IN (#{@group_ids.join(',')})"
    query = <<~SQL
      SELECT date_trunc('#{@interval}', memberships.created_at)::date AS interval, count(memberships.id) count
      FROM memberships
      WHERE #{group_filter}
      AND memberships.created_at >= '#{@start_at.to_date.iso8601}'
      AND memberships.created_at <= '#{@end_at.to_date.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def topics_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', topics.created_at)::date AS interval, count(topics.id) count
      FROM topics
      WHERE #{topic_group_filter}
      AND topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def comments_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', comments.created_at)::date AS interval, count(comments.id) count
      FROM comments
      LEFT JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id
      JOIN topics ON topics.id = events.topic_id
      WHERE #{topic_group_filter}
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def polls_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', polls.created_at)::date AS interval, count(polls.id) count
      FROM polls
      JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def stances_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', stances.created_at)::date AS interval, count(stances.id) count
      FROM stances
        LEFT JOIN polls ON stances.poll_id = polls.id
        LEFT JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND stances.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      AND stances.latest IS true
      AND stances.cast_at IS NOT NULL
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def outcomes_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', outcomes.created_at)::date AS interval, count(outcomes.id) count
      FROM outcomes
        LEFT JOIN polls ON outcomes.poll_id = polls.id
        LEFT JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND outcomes.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def topics_count
    query = <<~SQL
      SELECT count(topics.id) count
      FROM topics
      WHERE #{topic_group_filter}
      AND topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def discussion_topics_count
    query = <<~SQL
      SELECT count(topics.id) count
      FROM topics
      WHERE #{topic_group_filter}
      AND topics.topicable_type = 'Discussion'
      AND topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def poll_topics_count
    query = <<~SQL
      SELECT count(topics.id) count
      FROM topics
      WHERE #{topic_group_filter}
      AND topics.topicable_type = 'Poll'
      AND topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def polls_count
    query = <<~SQL
      SELECT count(polls.id) count
      FROM polls
      JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def polls_with_outcomes_count
    query = <<~SQL
      SELECT count(polls.id) count
      FROM polls
      JOIN topics ON topics.id = polls.topic_id
      INNER JOIN outcomes ON polls.id = outcomes.poll_id
      WHERE #{topic_group_filter}
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def tag_counts_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', topics.created_at)::date AS interval,
             tag,
             count(DISTINCT topics.id) count
      FROM topics
      CROSS JOIN unnest(topics.tags) tag
      WHERE #{topic_group_filter}
      AND topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      GROUP BY interval, tag
    SQL
    ActiveRecord::Base.connection.execute(query).each_with_object({}) do |row, counts|
      counts[row['tag']] ||= {}
      counts[row['tag']][row['interval']] = row['count']
    end
  end

  def tag_counts
    @tag_counts ||= begin
      counts = {}
      Topic
        .where(topic_group_filter)
        .where("topics.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'")
        .pluck(:tags).flatten.each do |tag|
          counts[tag] = counts.fetch(tag, 0) + 1
        end
      counts
    end
  end

  def tag_names
    tag_counts.keys.sort_by(&:downcase)
  end

  def tag_threads_per_user
    query = <<~SQL
      WITH tagged_topics AS (
        SELECT id topic_id, unnest(tags) tag
        FROM topics
        WHERE #{topic_group_filter(col: 'group_id')}
        AND cardinality(tags) > 0
      ),
      participations AS (
        SELECT tt.tag, d.author_id user_id, tt.topic_id
        FROM discussions d
        JOIN tagged_topics tt ON tt.topic_id = d.topic_id
        WHERE d.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION
        SELECT tt.tag, c.user_id, tt.topic_id
        FROM comments c
        JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = c.id
        JOIN tagged_topics tt ON tt.topic_id = events.topic_id
        WHERE c.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION
        SELECT tt.tag, p.author_id, tt.topic_id
        FROM polls p
        JOIN tagged_topics tt ON tt.topic_id = p.topic_id
        WHERE p.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION
        SELECT tt.tag, s.participant_id, tt.topic_id
        FROM stances s
        JOIN polls p ON s.poll_id = p.id
        JOIN tagged_topics tt ON tt.topic_id = p.topic_id
        WHERE s.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        AND s.latest IS true
        AND s.cast_at IS NOT NULL
        UNION
        SELECT tt.tag, o.author_id, tt.topic_id
        FROM outcomes o
        JOIN polls p ON o.poll_id = p.id
        JOIN tagged_topics tt ON tt.topic_id = p.topic_id
        WHERE o.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      )
      SELECT tag, user_id, count(DISTINCT topic_id) count
      FROM participations
      WHERE user_id IS NOT NULL
      GROUP BY tag, user_id
    SQL
    tag_user_counts ActiveRecord::Base.connection.execute(query)
  end

  def tag_threads_authored_per_user
    query = <<~SQL
      WITH tagged_topics AS (
        SELECT id topic_id, unnest(tags) tag
        FROM topics
        WHERE #{topic_group_filter(col: 'group_id')}
        AND cardinality(tags) > 0
      )
      SELECT tt.tag, a.user_id, count(DISTINCT tt.topic_id) count
      FROM (
        SELECT d.author_id user_id, d.topic_id
        FROM discussions d
        WHERE d.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION
        SELECT p.author_id, p.topic_id
        FROM polls p
        JOIN topics ON topics.id = p.topic_id
        WHERE topics.topicable_type = 'Poll'
        AND p.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      ) a
      JOIN tagged_topics tt ON tt.topic_id = a.topic_id
      WHERE a.user_id IS NOT NULL
      GROUP BY tt.tag, a.user_id
    SQL
    tag_user_counts ActiveRecord::Base.connection.execute(query)
  end

  def tag_user_counts(results)
    results.each_with_object({}) do |row, counts|
      counts[row['tag']] ||= {}
      counts[row['tag']][row['user_id']] = row['count']
    end
  end

  def discussions_per_user
    query = <<~SQL
      SELECT count(discussions.id) count, author_id user_id
      FROM discussions
      JOIN topics ON topics.id = discussions.topic_id
      WHERE #{topic_group_filter}
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by author_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def comments_per_user
    query = <<~SQL
      SELECT count(comments.id) count, comments.user_id
      FROM comments
      JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id
      JOIN topics ON topics.id = events.topic_id
      WHERE #{topic_group_filter}
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by comments.user_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def polls_per_user
    query = <<~SQL
      SELECT count(polls.id) count, author_id user_id
      FROM polls
      JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by author_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def outcomes_per_user
    query = <<~SQL
      SELECT count(outcomes.id) count, outcomes.author_id user_id
      FROM outcomes
      JOIN polls ON outcomes.poll_id = polls.id
      JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
      AND outcomes.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by outcomes.author_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def stances_per_user
    query = <<~SQL
      SELECT count(stances.id) count, participant_id
      FROM stances
      JOIN polls ON stances.poll_id = polls.id
      JOIN topics ON topics.id = polls.topic_id
      WHERE #{topic_group_filter}
        AND polls.anonymous = false
        AND stances.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        AND stances.latest IS true
        AND stances.cast_at IS NOT NULL
      group by participant_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'participant_id', 'count'
  end

  def reactions_per_user
    query = reaction_rows_query("SELECT count(reaction_id) count, user_id FROM reaction_rows GROUP BY user_id")
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def users
    if @direct_threads
      User.all
    else
      user_ids = Membership.where(group_id: @group_ids).pluck(:user_id).uniq
      User.where(id: user_ids)
    end
  end

  def users_per_country
    group_filter = @direct_threads ? "" : "AND memberships.group_id IN (#{@group_ids.join(',')})"
    query = <<~SQL
      SELECT count(DISTINCT users.id) count, country
      FROM users
      JOIN memberships ON memberships.user_id = users.id
      WHERE email_verified = true
      #{group_filter}
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def discussions_per_country
    query = <<~SQL
      SELECT count(discussions.id) count, country
      FROM discussions
      JOIN topics ON topics.id = discussions.topic_id
      JOIN users ON discussions.author_id = users.id
      WHERE #{topic_group_filter}
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def comments_per_country
    query = <<~SQL
      SELECT count(comments.id) count, country
      FROM comments
      JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id
      JOIN topics ON topics.id = events.topic_id AND topics.topicable_type = 'Discussion'
      JOIN discussions ON discussions.id = topics.topicable_id
      JOIN users ON comments.user_id = users.id
      WHERE #{topic_group_filter}
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def polls_per_country
    query = <<~SQL
      SELECT count(polls.id) count, country
      FROM polls
      JOIN topics ON topics.id = polls.topic_id
      JOIN users ON polls.author_id = users.id
      WHERE #{topic_group_filter}
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def outcomes_per_country
    query = <<~SQL
      SELECT count(outcomes.id) count, country
      FROM outcomes
      JOIN polls ON polls.id = outcomes.poll_id
      JOIN topics ON topics.id = polls.topic_id
      JOIN users ON outcomes.author_id = users.id
      WHERE #{topic_group_filter}
      AND outcomes.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def stances_per_country
    query = <<~SQL
      SELECT count(stances.id) count, country
      FROM stances
      JOIN polls ON stances.poll_id = polls.id
      JOIN topics ON topics.id = polls.topic_id
      JOIN users ON stances.participant_id = users.id
      WHERE #{topic_group_filter}
        AND polls.anonymous = false
        AND stances.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        AND stances.latest IS true
        AND stances.cast_at IS NOT NULL
      group by country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def reactions_per_country
    query = reaction_rows_query(<<~SQL)
      SELECT count(reaction_rows.reaction_id) count, users.country
      FROM reaction_rows
      JOIN users ON reaction_rows.user_id = users.id
      GROUP BY users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def reaction_rows_query(select_sql)
    <<~SQL
      WITH reaction_rows AS (
        SELECT reactions.id reaction_id, reactions.user_id
        FROM reactions
        JOIN comments ON reactions.reactable_id = comments.id AND reactions.reactable_type = 'Comment'
        JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id
        JOIN topics ON topics.id = events.topic_id
        WHERE #{topic_group_filter}
        AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION ALL
        SELECT reactions.id, reactions.user_id
        FROM reactions
        JOIN discussions ON reactions.reactable_id = discussions.id AND reactions.reactable_type = 'Discussion'
        JOIN topics ON topics.id = discussions.topic_id
        WHERE #{topic_group_filter}
        AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION ALL
        SELECT reactions.id, reactions.user_id
        FROM reactions
        JOIN polls ON reactions.reactable_id = polls.id AND reactions.reactable_type = 'Poll'
        JOIN topics ON topics.id = polls.topic_id
        WHERE #{topic_group_filter}
        AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION ALL
        SELECT reactions.id, reactions.user_id
        FROM reactions
        JOIN stances ON reactions.reactable_id = stances.id AND reactions.reactable_type = 'Stance'
        JOIN polls ON stances.poll_id = polls.id
        JOIN topics ON topics.id = polls.topic_id
        WHERE #{topic_group_filter}
        AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        UNION ALL
        SELECT reactions.id, reactions.user_id
        FROM reactions
        JOIN outcomes ON reactions.reactable_id = outcomes.id AND reactions.reactable_type = 'Outcome'
        JOIN polls ON outcomes.poll_id = polls.id
        JOIN topics ON topics.id = polls.topic_id
        WHERE #{topic_group_filter}
        AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      )
      #{select_sql}
    SQL
  end

  def countries
    users.pluck(:country).uniq.map {|c| c.nil? ? 'Unknown' : c }.sort
  end
end
