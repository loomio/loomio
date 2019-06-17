class AddInfoToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :info, :jsonb, default: {}, null: false
  end
end
