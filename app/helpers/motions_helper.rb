module MotionsHelper
  def motion_sparkline(motion)
    values = motion.vote_counts.values
    if values.sum == 0
      '0,0,0,0,1'
    else
      values.join(',')
    end
  end
end
