class RecountTopicAnonymousPollsCount < ActiveRecord::Migration[8.1]
  # Polls stopped recounting this column when topics replaced discussions as
  # their parent, so topics created since then can report zero anonymous polls.
  def up
    execute <<~SQL.squish
      UPDATE topics
      SET anonymous_polls_count = counts.anonymous_polls_count
      FROM (
        SELECT topics.id, COUNT(polls.id) AS anonymous_polls_count
        FROM topics
        LEFT JOIN polls ON polls.topic_id = topics.id AND polls.anonymous = TRUE
        GROUP BY topics.id
      ) counts
      WHERE topics.id = counts.id
        AND topics.anonymous_polls_count <> counts.anonymous_polls_count
    SQL
  end

  def down
  end
end
