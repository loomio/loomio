class RemoveVoterCanAddOptionsFromPolls < ActiveRecord::Migration[8.1]
  def change
    remove_column :polls, :voter_can_add_options, :boolean, default: false, null: false
  end
end
