class ProposalsClosingSoonJob < ActiveJob::Base
  def perform
    Motion.voting.where(:closing_at => this_hour_tomorrow).each do |motion|
      Events::MotionClosingSoon.publish!(motion)
    end
  end

  private

  def this_hour_tomorrow
    hour_start = 1.day.from_now.at_beginning_of_hour
    hour_finish = hour_start + 1.hour
    hour_start..hour_finish
  end
end
