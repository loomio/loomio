class Outcome < ActiveRecord::Base
  extend  HasCustomFields
  include MakesAnnouncements
  include HasMentions
  include Reactable
  include Translatable
  include HasCreatedEvent

  set_custom_fields :calendar_invite, :event_summary, :event_description, :event_location

  belongs_to :poll, required: true
  belongs_to :poll_option, required: false
  belongs_to :author, class_name: 'User', required: true
  has_many :stances, through: :poll
  has_many :events, as: :eventable
  has_many :documents, as: :model, dependent: :destroy

  delegate :title, to: :poll
  delegate :dates_as_options, to: :poll
  delegate :group, to: :poll
  delegate :group_id, to: :poll
  delegate :discussion, to: :poll
  delegate :discussion_id, to: :poll
  delegate :locale, to: :poll

  is_mentionable on: :statement
  is_translatable on: :statement

  validates :statement, presence: true, length: { maximum: Rails.application.secrets.max_message_length }
  validate :has_valid_poll_option

  def parent_event
    poll.created_event
  end

  def attendee_emails
     self.stances.joins(:participant).joins(:stance_choices)
    .where("stance_choices.poll_option_id": self.poll_option_id)
    .pluck(:"users.email").flatten.compact.uniq
  end

  def store_calendar_invite
    self.calendar_invite = CalendarInvite.new(self).to_ical
  end

  def has_valid_poll_option
    return if !self.poll_option_id || poll.poll_option_ids.include?(self.poll_option_id)
    errors.add(:poll_option_id, I18n.t(:"outcome.error.invalid_poll_option"))
  end
end
