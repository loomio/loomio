class AddPrivacyToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :private, :boolean, null: true
  end
end
