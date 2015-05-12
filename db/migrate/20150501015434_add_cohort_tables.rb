class AddCohortTables < ActiveRecord::Migration
  def change
    create_table :cohorts do |t|
      t.date :start_on
      t.date :end_on
    end

    add_column :groups, :cohort_id, :integer
    add_index :groups, :cohort_id

    create_table :group_measurements do |t|
      t.integer :group_id
      t.date    :period_end_on
      t.integer :members_count
      t.integer :admins_count
      t.integer :subgroups_count
      t.integer :invitations_count
      t.integer :discussions_count
      t.integer :proposals_count
      t.integer :comments_count
      t.integer :likes_count
      t.integer :group_visits_count
      t.integer :member_group_visits_count
      t.integer :organisation_visits_count
      t.integer :member_organisation_visits_count
    end

    add_index :group_measurements, :group_id
    add_index :group_measurements, :period_end_on
    add_index :group_measurements, [:group_id, :period_end_on], unique: true

    add_column :invitations, :created_at, :datetime
    add_column :invitations, :updated_at, :datetime
  end
end
