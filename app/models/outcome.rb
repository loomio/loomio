class Outcome < ApplicationRecord
  extend  HasCustomFields
  include HasEvents
  include HasMentions
  include Reactable
  include Translatable
  include HasCreatedEvent
  include HasEvents
  include HasRichText

  is_rich_text    on: :statement

  set_custom_fields :calendar_invite, :event_summary, :event_description, :event_location

  belongs_to :poll, required: true
  belongs_to :poll_option, required: false
  belongs_to :author, class_name: 'User', required: true
  has_many :stances, through: :poll
  has_many :documents, as: :model, dependent: :destroy

  %w(
    title poll_type dates_as_options group group_id groups discussion discussion_id
    locale mailer guest_group guest_group_id guest_members guest_invitations anyone_can_participate
    members
  ).each { |message| delegate message, to: :poll }

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
