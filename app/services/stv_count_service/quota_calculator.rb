module StvCountService
  module QuotaCalculator
    def self.calculate(total_votes, seats, type)
      case type.to_s
      when 'hare'
        Rational(total_votes, seats)
      else # 'droop'
        (total_votes / (seats + 1)).floor + 1
      end
    end
  end
end
