class Cohort < ActiveRecord::Base
  has_many :groups

  def organisations
    groups.where('parent_id IS NULL')
  end

  def activated_organisations
    #organisation_visits_count
    subquery = GroupMeasurement.select('DISTINCT group_id')
                               .where('organisation_member_visits_count > 5')
    organisations.where("id in (#{subquery.to_sql})")
  end
end
