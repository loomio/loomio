class AddSpecifiedVotersOnlyToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :specified_voters_only, :boolean, default: false, null: false
  end
end
