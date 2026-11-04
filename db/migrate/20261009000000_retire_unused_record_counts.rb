class RetireUnusedRecordCounts < ActiveRecord::Migration[8.1]
  def up
    # Retained counters keep their existing definitions and values. Historical
    # count repair must not hold application-wide write locks during deployment.
    remove_columns :groups, :closed_polls_count, :delegates_count, :discussion_templates_count, :subgroups_count
    remove_columns :topics, :anonymous_polls_count, :closed_polls_count, :members_count
    remove_column :tags, :taggings_count
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Retired counters are no longer maintained'
  end
end
