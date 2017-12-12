class AddClosedToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :closed, :boolean, default: false, null: false
  end
end
