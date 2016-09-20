class ProposalsClosingSoonJob < ActiveJob::Base
  def perform
    Motion.closing_soon_not_published(this_hour_tomorrow).each { |m| Events::MotionClosingSoon.publish!(m) }
  end

  private

  def this_hour_tomorrow
    hour_start = 1.day.from_now.at_beginning_of_hour
    hour_finish = hour_start + 1.hour
    hour_start..hour_finish
  end
end
