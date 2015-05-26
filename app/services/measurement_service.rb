class MeasurementService
  def self.measure_groups(period_end_on)
    # end_on is inclusive
    # period_end_on 2015-05-11 means we do where(:created_at < period_end_on + 1.day)

    GroupMeasurement.where(period_end_on: period_end_on).delete_all

    count_subqueries_str = subqueries.map do |hash|
      name = hash[:name]
      table = hash[:table]
      query = hash[:relation].where("#{table}.created_at < ?", period_end_on + 1.day).select("COUNT(#{table}.id)").to_sql
      "(#{query}) AS #{name}_count"
    end.join(", \n")

    count_subquery_names = subqueries.map {|hash| "#{hash[:name]}_count" }

    str = "
    WITH counts AS (
      SELECT
      id as group_id,
      DATE('#{period_end_on.to_s}') as period_end_on,
      (DATE('#{period_end_on.to_s}') - outer_groups.created_at::date) as age,
      #{count_subqueries_str}
      FROM groups AS outer_groups WHERE cohort_id IS NOT NULL ORDER by id ASC
    ) INSERT INTO group_measurements (group_id, age, period_end_on, #{count_subquery_names.join(', ')})
             SELECT group_id, age, period_end_on, #{count_subquery_names.join(', ')} FROM counts WHERE age > -1"
    ActiveRecord::Base.connection.execute str
  end


  def self.subqueries
    [
      {name: :members, table: :memberships, relation: Membership.active.where('group_id = outer_groups.id')},
      {name: :admins, table: :memberships, relation: Membership.active.admin.where('group_id = outer_groups.id')},
      {name: :subgroups, table: :groups, relation: Group.where('groups.parent_id = outer_groups.id')},
      {name: :invitations, table: :invitations, relation: Invitation.where(invitable_type: 'Group').where('invitable_id = outer_groups.id')},
      {name: :discussions, table: :discussions, relation: Discussion.published.where('group_id = outer_groups.id')},
      {name: :proposals, table: :motions, relation: Motion.joins(:discussion).where('discussions.group_id = outer_groups.id')},
      {name: :comments, table: :comments, relation: Comment.joins('JOIN discussions ON comments.discussion_id = discussions.id').where('discussions.group_id = outer_groups.id')},
      {name: :likes, table: :comment_votes, relation: CommentVote.joins('JOIN comments ON comment_votes.comment_id = comments.id JOIN discussions ON comments.discussion_id = discussions.id').where('discussions.group_id = outer_groups.id')},
      {name: :group_visits, table: :group_visits, relation: GroupVisit.where('group_id = outer_groups.id')},
      {name: :group_member_visits, table: :group_visits, relation: GroupVisit.where("member = true and group_id = outer_groups.id")},
      {name: :organisation_visits, table: :organisation_visits, relation: OrganisationVisit.where('organisation_id = outer_groups.id')},
      {name: :organisation_member_visits, table: :organisation_visits, relation: OrganisationVisit.where("member = true AND organisation_id = outer_groups.id")}
    ]
  end

  def self.measurement_names
    subqueries.map{|q| q[:name] }
  end
end
