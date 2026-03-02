module StvCountService
  def self.count(poll)
    ballots = extract_ballots(poll)
    seats = poll.stv_seats || 1
    method = poll.stv_method || 'scottish'
    quota_type = poll.stv_quota || 'droop'

    return empty_result(seats, method, quota_type) if ballots.empty?

    counter = case method
              when 'meek'
                MeekCounter.new(ballots, seats, quota_type, poll.poll_options)
              else
                ScottishCounter.new(ballots, seats, quota_type, poll.poll_options)
              end

    counter.count
  end

  def self.extract_ballots(poll)
    poll.stances.latest.decided.includes(:stance_choices).map do |stance|
      stance.stance_choices
            .sort_by { |sc| sc.score }
            .map(&:poll_option_id)
    end
  end

  def self.empty_result(seats, method, quota_type)
    {
      quota: 0,
      seats: seats,
      method: method,
      quota_type: quota_type,
      elected: [],
      tied: [],
      rounds: []
    }
  end
end
