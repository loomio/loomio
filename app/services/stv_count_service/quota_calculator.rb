module StvCountService
  module QuotaCalculator
    def self.calculate(total_votes, seats, type)
      case type.to_s
      when 'hare'
        total_votes.to_f / seats
      else # 'droop'
        (total_votes.to_f / (seats + 1)).floor + 1
      end
    end
  end
end
