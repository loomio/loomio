class MigrateMotionsClosedByUser
  def self.now
    Event.where("kind = ? AND user_id IS NOT NULL", "motion_closed").find_each do |event|
      event.kind = "motion_closed_by_user"
      event.save!
      puts event.id if (event.id % 100) == 0
    end
  end
end
