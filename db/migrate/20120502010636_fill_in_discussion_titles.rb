class FillInDiscussionTitles < ActiveRecord::Migration
  def up
    Discussion.all.each do |discussion|
      motion = discussion.current_motion
      if motion.nil?
        title = "(no title)"
      else
        title = motion.name
      end
      title = "(no title)" if title.blank?
      title = ActionController::Base.helpers.truncate(title, length: 150, separator: " ")
      discussion.title = title
      discussion.save!
    end
  end

  def down
  end
end
