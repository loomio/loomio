class AddThresholdPctToPollOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_options, :test_operator, :string
    add_column :poll_options, :test_percent, :integer
    add_column :poll_options, :test_against, :string
  end
end
