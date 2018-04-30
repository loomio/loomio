class AddStanceDataToPollOption < ActiveRecord::Migration[5.1]
  def change
    add_column :poll_options, :score_counts, :jsonb, default: {}, null: false
  end
end
