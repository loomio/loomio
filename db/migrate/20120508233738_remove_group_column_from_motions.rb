class RemoveGroupColumnFromMotions < ActiveRecord::Migration
  def up
    Motion.all.each do |motion|
      if motion.discussion.blank?
        discussion = Discussion.new
        discussion.group_id = motion.group_id
        discussion.title = motion.name
        discussion.author = motion.author
        discussion.save
        motion.discussion = discussion
        motion.save
      end
    end

    remove_column :motions, :group_id
  end

  def down
    add_column :motions, :group_id, :integer

    Motion.reset_column_information
    Motion.all.each do |motion|
      motion.group = motion.discussion.group
      motion.save
    end
  end
end
