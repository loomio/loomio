class AddDefaultDurationInDays < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :default_duration_in_days, :integer
  end
end
