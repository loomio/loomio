class AddDisableDiscussionToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :disable_discussion, :boolean
  end
end
