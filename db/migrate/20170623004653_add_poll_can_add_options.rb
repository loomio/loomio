class AddPollCanAddOptions < ActiveRecord::Migration
  def change
    add_column :polls, :voter_can_add_options, :boolean, default: false, null: false
  end
end
