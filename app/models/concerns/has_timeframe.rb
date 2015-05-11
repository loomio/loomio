module HasTimeframe
  extend ActiveSupport::Concern

  included do
    scope :within, ->(since, till, field = nil) { where("#{field || timeframe_field} BETWEEN ? AND ?", since || 100.years.ago, till || 100.years.from_now) }
    scope :until, ->(till) { within(nil, till) }
    scope :since, ->(since) { within(since, nil) }

    def self.has_timeframe?
      true
    end

    def self.timeframe_field
      :created_at
    end
  end

end