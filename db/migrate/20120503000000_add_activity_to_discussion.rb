class AddActivityToDiscussion < ActiveRecord::Migration
  def up
    add_column :discussions, :activity, :integer, default: 0
    execute "UPDATE discussions d, motions m SET d.activity = m.discussion_activity WHERE d.id = m.discussion_id"
    remove_column :motions, :discussion_activity
  end

  def down
    add_column :motions, :discussion_activity, :integer, default: 0
    execute "UPDATE motions m, discussions d SET m.discussion_activity = d.activity WHERE m.discussion_id = d.id"
    remove_column :discussions, :activity
  end
end
