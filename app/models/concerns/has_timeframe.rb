module HasTimeframe
  extend ActiveSupport::Concern

  included do
    scope :within, ->(since, till, field = nil) { where("#{self.table_name}.#{field || :created_at} BETWEEN ? AND ?", since || 100.years.ago, till || 100.years.from_now) }
    scope :until, ->(till) { within(nil, till) }
    scope :since, ->(since) { within(since, nil) }

    def self.has_timeframe?
      true
    end

  end

end