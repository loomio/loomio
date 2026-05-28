class ReparentOrphanedComments < ActiveRecord::Migration[7.1]
  def up
    # Comments whose parent comment was hard-deleted (via CommentService.destroy)
    # have parent_type='Comment' but parent_id pointing to a non-existent record.
    # Re-parent them to the topicable (discussion or poll) of their topic.
    execute <<~SQL
      UPDATE comments
      SET parent_type = sq.topicable_type,
          parent_id   = sq.topicable_id
      FROM (
        SELECT c.id AS comment_id, t.topicable_type, t.topicable_id
        FROM comments c
        JOIN events e ON e.eventable_type = 'Comment' AND e.eventable_id = c.id
        JOIN topics t ON t.id = e.topic_id
        WHERE c.parent_type = 'Comment'
          AND NOT EXISTS (
            SELECT 1 FROM comments pc WHERE pc.id = c.parent_id
          )
      ) AS sq
      WHERE comments.id = sq.comment_id
    SQL
  end
end
