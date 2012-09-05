class RenameCloseMotionEventToMotionClosed < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def up
    Event.where(:kind => "close_motion").each do |event|
      event.kind = "motion_closed"
      event.save :validate => false
    end
  end

  def down
    Event.where(:kind => "motion_closed").each do |event|
      event.kind = "close_motion"
      event.save :validate => false
    end
  end
end
