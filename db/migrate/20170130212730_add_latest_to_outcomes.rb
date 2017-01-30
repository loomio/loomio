class AddLatestToOutcomes < ActiveRecord::Migration
  def change
    add_column :outcomes, :latest, :boolean, default: true, null: false
  end
end
