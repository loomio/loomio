class UpdateCounterCaches < ActiveRecord::Migration
  def up
    remove_column :groups, :motions_count
    add_column :discussions, :motions_count, :integer, default: 0

    Discussion.reset_column_information
    Group.reset_column_information

    Group.update_all discussions_count: 0
    Discussion.update_all motions_count: 0

    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Group.count )

    Group.find_each do |group|
      progress_bar.increment
      discussion_ids = Discussion.published.where(group_id: group.id).pluck(:id)
      Group.update_counters group.id, discussions_count: discussion_ids.size if discussion_ids.size > 0
      discussion_ids.each do |discussion_id|
        motion_ids = Motion.where(discussion_id: discussion_id).pluck(:id)
        Discussion.update_counters discussion_id, motions_count: motion_ids.size if motion_ids.size > 0 
      end
    end
  end

  def down
    remove_column :discussions, :motions_count
    add_column :groups, :motions_count, :integer, default: 0
  end
end
