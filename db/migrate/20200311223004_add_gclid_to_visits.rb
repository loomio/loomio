class AddGclidToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :ahoy_visits, :gclid, :string
  end
end
