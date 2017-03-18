class AddMatrixCountsToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :matrix_counts, :jsonb, default: [], null: false
  end
end
