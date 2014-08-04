class ProposalsClosingSoonJob
  attr_accessor :time_window

  def initialize
    one_day_from_now = 1.day.from_now
    beginning_of_hour = one_day_from_now.at_beginning_of_hour
    end_of_hour = beginning_of_hour + 1.hour
    @time_window = beginning_of_hour ... end_of_hour
  end

  def perform
    Motion.voting.where(:closing_at => time_window).each do |motion|
      Events::MotionClosingSoon.publish!(motion)
    end
  end
end
