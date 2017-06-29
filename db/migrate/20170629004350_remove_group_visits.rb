class RemoveGroupVisits < ActiveRecord::Migration
  def change
    drop_table :group_visits
    drop_table :organisation_visits
  end
end
