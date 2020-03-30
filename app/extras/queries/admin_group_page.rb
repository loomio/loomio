class Queries::AdminGroupPage
  # def self.visits_per_day_sql(group)
  #   "select date_trunc('day', created_at) date, count(id) from organisation_visits where organisation_id = #{group.id} group by date order by date"
  # end

  def self.members_per_day_sql(group)
    "select date_trunc('day', created_at) date, count(distinct user_id) from memberships where group_id = #{group.id} group by date order by date"
  end

  def self.threads_per_day_sql(group)
    "select date_trunc('day', created_at) date, count(id) from discussions where group_id IN (#{group.id_and_subgroup_ids.join(',')}) group by date order by date"
  end

  def self.polls_per_day_sql(group)
    "select date_trunc('day', created_at) date, count(id) from polls where group_id IN (#{group.id_and_subgroup_ids.join(',')}) group by date order by date"
  end

  def self.execute(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.run_per_day(sql)
    massage execute(sql)
  end

  def self.massage(records)
    records.to_a.map { |record| { date: record["date"], count: record["count"] }  }
  end

  def self.fetch_data(group)
    {
      # visits: run_per_day(visits_per_day_sql(group)),
      members: run_per_day(members_per_day_sql(group)),
      threads: run_per_day(threads_per_day_sql(group)),
      polls: run_per_day(polls_per_day_sql(group))
    }
  end

  # def self.visits_count(group)
  #   OrganisationVisit.where(organisation_id: group.id).count
  # end

  def self.thread_items_count(group)
    Discussion.where(group_id: group.id_and_subgroup_ids).sum(:items_count)
  end

  def self.discussions_count(group)
    Discussion.where(group_id: group.id_and_subgroup_ids).count
  end

  def self.polls_count(group)
    Poll.where(group_id: group.id_and_subgroup_ids).count
  end

end
