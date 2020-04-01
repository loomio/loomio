class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[5.2]
  def change
    rename_table :visits, :ahoy_visits

    add_column :ahoy_visits, :visit_token, :string

    rename_column :ahoy_visits, :visitor_id, :visitor_token
    change_column :ahoy_visits, :visitor_token, :string


    add_column :ahoy_visits, :latitude, :uuid
    add_column :ahoy_visits, :longitude, :uuid

    add_index  :ahoy_visits, [:visit_token], unique: true

    add_index :ahoy_events, [:name, :time]
  end
end
