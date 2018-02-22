class UsageReports < ActiveRecord::Migration[4.2]
  def change
    create_table :usage_reports do |t|
      t.integer :groups_count
      t.integer :users_count
      t.integer :discussions_count
      t.integer :polls_count
      t.integer :comments_count
      t.integer :stances_count
      t.integer :visits_count
      t.string  :canonical_host
      t.timestamps
    end
  end
end
