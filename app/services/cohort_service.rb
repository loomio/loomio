class CohortService
  def self.tag_groups
    Cohort.find_each do |cohort|
      Group.where('created_at >= :start_on AND created_at < :end_on_plus_one', {start_on: cohort.start_on, end_on_plus_one: cohort.end_on + 1.day}).update_all("cohort_id = #{cohort.id}")
    end
  end
end
