class Cohort < ActiveRecord::Base
  has_many :groups

  def homepage_visits
    Ahoy::Event.where(name: '$view')
               .where("properties ->> 'url'= 'https://www.loomio.org/'")
               .where(time: start_on..(end_on + 1.day))
  end

  def organisations
    groups.where('parent_id IS NULL')
  end

  def activated_organisations
    # organisation_visits_count
    subquery = GroupMeasurement.select('DISTINCT group_id')
                               .where('organisation_member_visits_count > 5')
    organisations.where("id in (#{subquery.to_sql})")
  end

  def retained_organisations
    min_age = 20
    min_activity = 20
    q = "SELECT DISTINCT group_id
         FROM group_measurements o_gm
         JOIN groups o_g on o_gm.group_id = o_g.id
         WHERE o_g.cohort_id = #{id}
         AND EXISTS (
           SELECT * FROM group_measurements i_gm
           WHERE i_gm.group_id = o_gm.group_id
           AND o_gm.age > #{min_age} AND i_gm.age = #{min_age}
           AND o_gm.organisation_member_visits_count > (i_gm.organisation_member_visits_count + #{min_activity}) )"
    retained_organisation_ids = ActiveRecord::Base.connection.exec_query(q).rows.flatten.map(&:to_i)

    Group.parents_only.where(id: retained_organisation_ids)
  end

  def paying_organisations
    0
  end

end
