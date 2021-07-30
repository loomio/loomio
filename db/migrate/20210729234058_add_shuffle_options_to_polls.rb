class AddShuffleOptionsToPolls < ActiveRecord::Migration[6.0]
  def change
    add_column :polls, :shuffle_options, :boolean, default: false, null: false
  end
end
