module HasTimeframe
  extend ActiveSupport::Concern

  included do
    scope :within, ->(since, till, field = nil) {
      col = (field && column_names.include?(field.to_s)) ? field : :created_at
      where("#{table_name}.#{col} BETWEEN ? AND ?", since || 100.years.ago, till || 100.years.from_now)
    }
    scope :until, ->(till) { within(nil, till) }
    scope :since, ->(since) { within(since, nil) }

    def self.has_timeframe?
      true
    end
  end
end