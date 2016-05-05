class LocateGroupsJob < ActiveJob::Base
  def perform(last_active)
    group_ids = Discussion.select('DISTINCT(group_id) group_id, last_activity_at').
                 where('last_activity_at > ?', last_active).
                 order('last_activity_at desc').map(&:group_id)


    Group.where(id: group_ids).each do |group|
      sql = "FROM users
             INNER JOIN memberships ON
               memberships.user_id = users.id AND
               memberships.group_id = #{group.id}
             GROUP BY 1
             ORDER BY count(*) DESC
             LIMIT 1"

      ActiveRecord::Base.connection.execute("
        SELECT * FROM ( SELECT country #{sql} ) country,
                      ( SELECT region #{sql} ) region,
                      ( SELECT city #{sql} ) city").each do |row|
        group.update_attributes(country: row['country'],
                                region: row['region'],
                                city: row['city'])
      end
    end
  end
end
