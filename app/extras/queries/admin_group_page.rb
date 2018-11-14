class Queries::AdminGroupPage
  def self.visits(group_id)
    query = "select date_trunc('day', created_at) date, count(id) from organisation_visits where organisation_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.massage(records)
  end

  def self.members(group_id)
    query = "select date_trunc('day', created_at) date, count(distinct user_id) from memberships where group_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.massage(records)
  end

  def self.threads(group_id)
    query = "select date_trunc('day', created_at) date, count(id) from discussions where group_id = #{group_id} group by date order by date;"
    records = self.execute(query)
    self.massage(records)
  end

  def self.execute(query_string)
    ActiveRecord::Base.connection.execute(query_string).to_a
  end

  def self.massage(records)
    records
      .map { |record| { date: record["date"], count: record["count"] }  }
      .reduce([]) do |sofar, record|
        if sofar.empty?
          [record]
        else
          sofar + [{ date: record[:date], count: (sofar.last[:count] || 0) + record[:count] }]
        end
      end
  end

  def self.fetch_data(group_id)
    { visits: self.visits(group_id), members: self.members(group_id), threads: self.threads(group_id) }.to_json
  end
end
