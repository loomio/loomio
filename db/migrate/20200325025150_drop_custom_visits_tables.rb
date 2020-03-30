class DropCustomVisitsTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :group_visits
    drop_table :organisation_visits
  end
end
