class ReportService
  def initialize(interval: 'month', group_ids: nil, start_at: 6.months.ago, end_at: 1.minute.ago)
    @interval = interval
    @group_ids = group_ids
    @start_at = start_at
    @end_at = end_at
    @direct_threads = @group_ids.include?(0)
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

  # need to remember to sanitize group ids, any other args
  def rows_to_hash(results, name_a = 'interval', name_b = 'count')
    results.to_a.map {|row| [row[name_a], row[name_b]]}.to_h
  end

  def memberships_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', memberships.created_at)::date AS interval, count(memberships.id) count
      FROM memberships
      WHERE group_id IN (#{@group_ids.join(',')})
      AND memberships.created_at >= '#{@start_at.to_date.iso8601}'
      AND memberships.created_at <= '#{@end_at.to_date.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def discussions_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', discussions.created_at)::date AS interval, count(discussions.id) count
      FROM discussions
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def comments_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', comments.created_at)::date AS interval, count(comments.id) count
      FROM comments
        LEFT JOIN discussions ON comments.discussion_id = discussions.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def polls_per_interval
    query = <<~SQL
      SELECT date_trunc('#{@interval}', polls.created_at)::date AS interval, count(polls.id) count
      FROM polls
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND outcomes.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by interval
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute query
  end

  def discussions_count
    query = <<~SQL
      SELECT count(discussions.id) count
      FROM discussions
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def polls_count
    query = <<~SQL
      SELECT count(polls.id) count
      FROM polls
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def discussions_with_polls_count
    query = <<~SQL
      SELECT count(discussions.id) count
      FROM discussions INNER JOIN polls ON discussions.id = polls.discussion_id
      WHERE (discussions.group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR discussions.group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def polls_with_outcomes_count
    query = <<~SQL
      SELECT count(polls.id) count
      FROM polls INNER JOIN outcomes ON polls.id = outcomes.poll_id
      WHERE (group_id IN (#{@group_ids.join(',')})  #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).to_a.first['count']
  end

  def discussion_ids
    query = <<~SQL
      SELECT discussions.id
      FROM discussions
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).map { |row| row['id'] }
  end

  def poll_ids
    query = <<~SQL
      SELECT polls.id
      FROM polls
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND polls.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
    SQL
    ActiveRecord::Base.connection.execute(query).map { |row| row['id'] }
  end

  def discussion_tag_counts
    tag_counts = {}
    Discussion.where(id: discussion_ids).each do |discussion|
      discussion.tags.each {|tag| tag_counts[tag] = tag_counts.fetch(tag, 0) + 1 }
    end
    tag_counts
  end

  def poll_tag_counts
    tag_counts = {}
    Poll.where(id: poll_ids).each do |poll|
      poll.tags.each {|tag| tag_counts[tag] = tag_counts.fetch(tag, 0) + 1 }
    end
    tag_counts
  end

  def tag_counts
    total_counts = {}
    discussion_tag_counts.each_pair {|tag, count| total_counts[tag] = total_counts.fetch(tag, 0) + count }
    poll_tag_counts.each_pair {|tag, count| total_counts[tag] = total_counts.fetch(tag, 0) + count }
    total_counts
  end

  def tag_names
    (discussion_tag_counts.keys + poll_tag_counts.keys).uniq.sort
  end

  def discussions_per_user
    query = <<~SQL
      SELECT count(id) count, author_id user_id
      FROM discussions
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by author_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def comments_per_user
    query = <<~SQL
      SELECT count(comments.id) count, user_id
      FROM comments
      JOIN discussions ON comments.discussion_id = discussions.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by user_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'user_id', 'count'
  end

  def polls_per_user
    query = <<~SQL
      SELECT count(id) count, author_id user_id
      FROM polls
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
        AND polls.anonymous = false
        AND stances.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        AND stances.latest IS true
        AND stances.cast_at IS NOT NULL
      group by participant_id
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'participant_id', 'count'
  end

  def reactions_per_user
    queries = []
    data = {}

    queries.push <<~SQL
      SELECT count(reactions.id) count, reactions.user_id user_id
      FROM reactions
      JOIN comments ON reactions.reactable_id = comments.id AND reactions.reactable_type = 'Comment'
      JOIN discussions ON comments.discussion_id = discussions.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by reactions.user_id
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, reactions.user_id user_id
      FROM reactions
      JOIN discussions ON reactions.reactable_id = discussions.id AND reactions.reactable_type = 'Discussion'
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by reactions.user_id
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, reactions.user_id user_id
      FROM reactions
      JOIN polls ON reactions.reactable_id = polls.id AND reactions.reactable_type = 'Poll'
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by reactions.user_id
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, reactions.user_id user_id
      FROM reactions
      JOIN stances ON reactions.reactable_id = stances.id AND reactions.reactable_type = 'Stance'
      JOIN polls ON stances.poll_id = polls.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by reactions.user_id
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, reactions.user_id user_id
      FROM reactions
      JOIN outcomes ON reactions.reactable_id = outcomes.id AND reactions.reactable_type = 'Outcome'
      JOIN polls ON outcomes.poll_id = polls.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by reactions.user_id
    SQL

    queries.each do |query|
      rows_to_hash(ActiveRecord::Base.connection.execute(query), 'user_id', 'count').each_pair do |k, v|
        data[k] = data.fetch(k, 0) + v
      end
    end
    data
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
    query = <<~SQL
      SELECT count(DISTINCT users.id) count, country
      FROM users
      JOIN memberships ON memberships.user_id = users.id
      WHERE email_verified = true
      #{@direct_threads ? '' : "AND memberships.group_id IN (#{@group_ids.join(',')})"}
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def discussions_per_country
    query = <<~SQL
      SELECT count(discussions.id) count, country
      FROM discussions
      JOIN users ON discussions.author_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND discussions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def comments_per_country
    query = <<~SQL
      SELECT count(comments.id) count, country
      FROM comments
      JOIN discussions ON comments.discussion_id = discussions.id
      JOIN users ON comments.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND comments.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by users.country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def polls_per_country
    query = <<~SQL
      SELECT count(polls.id) count, country
      FROM polls
      JOIN users ON polls.author_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      JOIN users ON outcomes.author_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
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
      JOIN users ON stances.participant_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
        AND polls.anonymous = false
        AND stances.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
        AND stances.latest IS true
        AND stances.cast_at IS NOT NULL
      group by country
    SQL
    rows_to_hash ActiveRecord::Base.connection.execute(query), 'country', 'count'
  end

  def reactions_per_country
    queries = []
    data = {}

    queries.push <<~SQL
      SELECT count(reactions.id) count, country
      FROM reactions
      JOIN comments ON reactions.reactable_id = comments.id AND reactions.reactable_type = 'Comment'
      JOIN discussions ON comments.discussion_id = discussions.id
      JOIN users ON reactions.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by country
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, country
      FROM reactions
      JOIN discussions ON reactions.reactable_id = discussions.id AND reactions.reactable_type = 'Discussion'
      JOIN users ON reactions.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by country
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, country
      FROM reactions
      JOIN polls ON reactions.reactable_id = polls.id AND reactions.reactable_type = 'Poll'
      JOIN users ON reactions.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by country
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, country
      FROM reactions
      JOIN stances ON reactions.reactable_id = stances.id AND reactions.reactable_type = 'Stance'
      JOIN polls ON stances.poll_id = polls.id
      JOIN users ON reactions.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by country
    SQL

    queries.push <<~SQL
      SELECT count(reactions.id) count, country
      FROM reactions
      JOIN outcomes ON reactions.reactable_id = outcomes.id AND reactions.reactable_type = 'Outcome'
      JOIN polls ON outcomes.poll_id = polls.id
      JOIN users ON reactions.user_id = users.id
      WHERE (group_id IN (#{@group_ids.join(',')}) #{@direct_threads ? 'OR group_id IS NULL' : ''})
      AND reactions.created_at BETWEEN '#{@start_at.iso8601}' AND '#{@end_at.iso8601}'
      group by country
    SQL

    queries.each do |query|
      rows_to_hash(ActiveRecord::Base.connection.execute(query), 'country', 'count').each_pair do |k, v|
        data[k] = data.fetch(k, 0) + v
      end
    end
    data
  end

  def countries
    users.pluck(:country).uniq.map {|c| c.nil? ? 'Unknown' : c }.sort
  end
end
