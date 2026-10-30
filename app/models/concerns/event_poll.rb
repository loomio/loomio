module EventPoll
  extend ActiveSupport::Concern

  SCHEDULE_FIELDS = %w[event_starts_at event_ends_at event_all_day].freeze
  CALENDAR_FIELDS = (SCHEDULE_FIELDS + %w[title details details_format event_location event_cancelled_at discarded_at]).freeze
  ATTENDANCE_ICONS = %w[agree abstain disagree].freeze

  def self.validate_attendance(record, icons:)
    record.errors.add(:poll_options, :invalid) unless icons.tally == ATTENDANCE_ICONS.tally
    record.errors.add(:anonymous, :invalid) if record.anonymous?
    record.errors.add(:weighted_voting, :invalid) if record.weighted_voting?
    record.errors.add(:score_min, :invalid) unless record.score_min == 1
    record.errors.add(:score_max, :invalid) unless record.score_max == 1
    record.errors.add(:choice_count_min, :invalid) unless record.choice_count_min == 1
    record.errors.add(:choice_count_max, :invalid) unless record.choice_count_max == 1
    record.errors.add(:stance_reason_required, :invalid) unless %w[optional disabled].include?(record.stance_reason_required)
    record.errors.add(:poll_option_name_format, :invalid) unless record.poll_option_name_format == 'plain'
    record.errors.add(:show_none_of_the_above, :invalid) if record.show_none_of_the_above
  end

  included do
    belongs_to :source_outcome, class_name: 'Outcome', optional: true
    has_many :calendar_invitations, dependent: :destroy
    before_validation :assign_calendar_uid
    validate :event_configuration, if: :event?
    after_update_commit :deliver_calendar_changes, if: -> { event? && saved_change_to_calendar_sequence? }
  end

  def event?
    poll_type == 'event'
  end

  def event_cancelled?
    event_cancelled_at.present? || discarded?
  end

  def calendar_changes?
    event? && CALENDAR_FIELDS.any? { |field| will_save_change_to_attribute?(field) }
  end

  def event_schedule_changes?
    event? && SCHEDULE_FIELDS.any? { |field| will_save_change_to_attribute?(field) }
  end

  private

  def assign_calendar_uid
    self.calendar_uid ||= "#{SecureRandom.uuid}@loomio" if event?
  end

  # Calendar replies have fixed attendance meanings. Enforce them where polls
  # are saved so templates and API clients cannot create an incompatible ballot.
  def event_configuration
    errors.add(:closed_at, :invalid) if event_cancelled_at && closed_at.nil?
    errors.add(:event_starts_at, :blank) unless event_starts_at
    errors.add(:event_ends_at, :blank) unless event_ends_at
    if event_starts_at && event_ends_at && event_ends_at <= event_starts_at
      errors.add(:event_ends_at, :invalid)
    end
    errors.add(:time_zone, :invalid) unless ActiveSupport::TimeZone[time_zone.to_s]
    options = poll_options.reject(&:marked_for_destruction?)
    EventPoll.validate_attendance(self, icons: options.map(&:icon))
    if event_all_day? && event_starts_at && event_ends_at && ActiveSupport::TimeZone[time_zone.to_s]
      [event_starts_at, event_ends_at].each do |time|
        errors.add(:event_all_day, :invalid) unless time.in_time_zone(time_zone) == time.in_time_zone(time_zone).beginning_of_day
      end
    end
  end

  def deliver_calendar_changes
    CalendarUpdateWorker.perform_later(id)
  end
end
