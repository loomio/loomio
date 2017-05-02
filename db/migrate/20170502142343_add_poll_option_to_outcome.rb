class AddPollOptionToOutcome < ActiveRecord::Migration
  def change
    add_column :outcomes, :poll_option_id, :integer, null: true
  end
end
