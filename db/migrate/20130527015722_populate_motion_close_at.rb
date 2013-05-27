class PopulateMotionCloseAt < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
  end

  def up
    # find motions without close_at and set to 7 days from now
    Motion.where(close_at: nil).each do |m|
      m.close_at = 7.days.from_now
      m.save(validate: false)
    end

    # find motions without close_at_date
    # set close_at_date and close_at_time to close_at.date, close_at.strftime
    Motion.where(close_at_date: nil).find_each do |m|
      m.close_at_date = m.close_at.to_date
      m.close_at_time = m.close_at.strftime("%H:%M")
      m.close_at_time_zone = "UTC"
      m.save(validate: false)
    end
  end

  def down
  end
end
