class AddThresholdPctToPollOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_options, :threshold_pct, :integer
  end
end
