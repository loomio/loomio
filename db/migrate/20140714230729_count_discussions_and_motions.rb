class CountDiscussionsAndMotions < ActiveRecord::Migration
  def up
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
  end
end
