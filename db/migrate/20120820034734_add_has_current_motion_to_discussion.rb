class AddHasCurrentMotionToDiscussion < ActiveRecord::Migration
  class Discussion < ActiveRecord::Base
    has_many :motions
    def current_motion
      motions.where("phase = 'voting'").last
    end
  end

  def up
    add_column :discussions, :has_current_motion, :boolean, :default => false

    Discussion.reset_column_information
    Discussion.all.each do |discussion|
      if discussion.current_motion
        discussion.has_current_motion = true
        discussion.save!
      end
    end
  end

  def down
    remove_column :discussions, :has_current_motion
  end
end
