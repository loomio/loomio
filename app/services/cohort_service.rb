class CohortService
  def self.tag_groups
    Cohort.find_each do |cohort|
      Group.where('created_at >= :start_on AND created_at <= :end_on', {start_on: cohort.start_on, end_on: cohort.end_on}).update_all("cohort_id = #{cohort.id}")
    end
  end
end
