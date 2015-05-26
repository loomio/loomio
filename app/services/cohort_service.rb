class CohortService
  def self.tag_groups
    Cohort.find_each do |cohort|
      Group.where('created_at >= :start_on AND created_at < :end_on_plus_one', {start_on: cohort.start_on, end_on_plus_one: cohort.end_on + 1.day}).update_all("cohort_id = #{cohort.id}")
    end
  end

  def self.column_for_measurement(measurement)
    GroupMeasurement.column_names.include?(measurement+"_count")
  end

  def self.avg_by_age(cohort: , measurement: , max_age: 30)

    query = "
    SELECT
      avg(gm.#{sanitize_measurement(measurement)}_count),
      age
    FROM group_measurements gm
    JOIN groups g ON gm.group_id = g.id
    WHERE g.cohort_id = #{Integer(cohort.id)} and age > -1 AND age < #{Integer(max_age)}
    GROUP BY age ORDER by age"

    ActiveRecord::Base.connection.exec_query(query)
  end

  def self.sanitize_measurement(measurement)
    if MeasurementService.measurement_names.include? measurement.to_sym
      measurement
    else
      raise "Invalid measurement name: #{measurement}"
    end
  end
end
