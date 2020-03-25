class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[5.2]
  def change
    rename_table :visits, :ahoy_visits
    rename_column :ahoy_visits, :id, :visit_token
    rename_column :ahoy_visits, :visitor_id, :visitor_token
    add_column :ahoy_visits, :latitude, :uuid
    add_column :ahoy_visits, :longitude, :uuid
    add_index  :ahoy_visits, [:visit_token], unique: true

    add_index :ahoy_events, [:name, :time]
    add_index :ahoy_events, :properties, using: :gin, opclass: :jsonb_path_ops
  end
end
