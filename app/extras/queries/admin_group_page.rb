class Queries::AdminGroupPage
  def self.visits(group_id)
    query = "select date_trunc('day', created_at) date, count(id) from organisation_visits where organisation_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.jsonify(records)
  end

  def self.members(group_id)
    query = "select date_trunc('day', created_at) date, count(distinct user_id) from memberships where group_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.jsonify(records)
  end

  def self.threads(group_id)
    query = "select date_trunc('day', created_at) date, count(id) from discussions where group_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.jsonify(records)
  end

  def self.execute(query_string)
    ActiveRecord::Base.connection.execute(query_string).to_a
  end

  def self.jsonify(records)
    records.map { |r| { date: r["date"], count: r["count"] }  }.to_json
  end
end
