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
    subquery = GroupMeasurement.select('DISTINCT group_id')
                               .where('organisation_member_visits_count > 20')
                               .where('age > 20')
    organisations.where("id in (#{subquery.to_sql})")
  end

  def paying_organisations
    0
  end

end
