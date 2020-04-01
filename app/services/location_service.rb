class LocationService
  def self.locate_users_from_visits(within_last: '70 minutes')
    # intended to be run hourly by default
    update_sql =
   "UPDATE users
    SET country = subquery.country,
        region = subquery.region,
        city = subquery.city
    FROM (
      SELECT DISTINCT(user_id) user_id, country, city, region, started_at
      FROM ahoy_visits
      WHERE started_at > (CURRENT_TIMESTAMP - interval '#{within_last}')
        AND country is not null
      ORDER BY started_at DESC
    ) AS subquery
    WHERE users.id = subquery.user_id;"

    ActiveRecord::Base.connection.execute update_sql
  end

  def self.locate_groups(active_since: 70.minutes.ago)
    group_ids = Discussion.select('DISTINCT(group_id) group_id, last_activity_at').
                 where('last_activity_at > ?', active_since).
                 order('last_activity_at desc').map(&:group_id)


    Group.where(id: group_ids).each do |group|
      ActiveRecord::Base.connection.execute("
        SELECT * FROM #{most_common(group, "country")},
                      #{most_common(group, "region")},
                      #{most_common(group, "city")} ").each do |row|
        group.update_attributes(country: row['country'],
                                region: row['region'],
                                city: row['city'])
      end
    end
  end

  private
  def self.most_common(group, column)
    "(SELECT #{column} FROM users
     INNER JOIN memberships ON
       memberships.user_id = users.id AND
       memberships.group_id = #{group.id}
     WHERE #{column} IS NOT NULL
     GROUP BY 1
     ORDER BY count(*) DESC
     LIMIT 1) #{column}"
  end
end
