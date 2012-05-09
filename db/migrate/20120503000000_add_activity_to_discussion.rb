class AddActivityToDiscussion < ActiveRecord::Migration
  def up
    add_column :discussions, :activity, :integer, default: 0
    execute "UPDATE discussions d SET activity = (SELECT discussion_activity FROM motions m WHERE d.id = m.discussion_id)"
    remove_column :motions, :discussion_activity
  end

  def down
    add_column :motions, :discussion_activity, :integer, default: 0
    execute "UPDATE motions m SET discussion_activity = (SELECT activity FROM discussions d WHERE m.discussion_id = d.id)"
    remove_column :discussions, :activity
  end
end
