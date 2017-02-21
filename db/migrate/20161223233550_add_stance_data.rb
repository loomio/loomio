class AddStanceData < ActiveRecord::Migration
  def change
    add_column :polls, :stance_data, :jsonb, default: {}
  end
end
