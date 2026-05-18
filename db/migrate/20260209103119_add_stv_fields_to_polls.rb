class AddStvFieldsToPolls < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :stv_seats, :integer
    add_column :polls, :stv_method, :string
    add_column :polls, :stv_quota, :string
  end
end
