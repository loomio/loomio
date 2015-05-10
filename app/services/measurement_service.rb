class MeasurementService
  def self.measure_groups
    str = "
    WITH counts AS (
      SELECT
      id as group_id,
        current_date as measured_on,
        #{subqueries.keys.map { |key| "(#{sql_for(key)}) AS #{key}" }.join(", \n")}
      FROM groups ORDER by id ASC
    ) INSERT INTO group_measurements (group_id, measured_on, #{subqueries.keys.join(', ')})
             SELECT group_id, measured_on, #{subqueries.keys.join(', ')} FROM counts; "
    ActiveRecord::Base.connection.execute str
  end

  def self.sql_for(name)
    subqueries[name]
  end

  def self.subqueries
    {
      members_count: Membership.active.where('group_id = groups.id').select('COUNT(memberships.id)').to_sql,
      admins_count: Membership.active.admin.where('group_id = groups.id').select('COUNT(memberships.id)').to_sql,
      subgroups_count: 'SELECT COUNT(id) FROM groups AS subgroups WHERE subgroups.parent_id = groups.id',
      invitations_count: Invitation.where(invitable_type: 'Group').where('invitable_id = groups.id').select('COUNT(invitations.id)').to_sql,
      discussions_count: Discussion.published.where('group_id = groups.id').select('COUNT(discussions.id)').to_sql,
      proposals_count: Motion.joins(:discussion).where('discussions.group_id = groups.id').select('COUNT(motions.id)').to_sql,
      comments_count: Comment.joins('JOIN discussions ON comments.discussion_id = discussions.id').where('discussions.group_id = groups.id').select('COUNT(comments.id)').to_sql,
      likes_count: CommentVote.joins('JOIN comments ON comment_votes.comment_id = comments.id JOIN discussions ON comments.discussion_id = discussions.id').where('discussions.group_id = groups.id').select('COUNT(comment_votes.id)').to_sql
    }
  end
end
