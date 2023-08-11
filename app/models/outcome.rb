class Outcome < ApplicationRecord
  include CustomCounterCache::Model
  extend  HasCustomFields
  include HasEvents
  include HasMentions
  include Reactable
  include Translatable
  include HasCreatedEvent
  include HasEvents
  include HasRichText
  
  include PgSearch::Model
  multisearchable(
    against: [:statement, :author_name],
    additional_attributes: -> (o) { 
      {
        poll_id: o.poll_id,
        group_id: o.poll.group_id,
        discussion_id: o.poll.discussion_id,
        author_id: o.author_id
      } 
    }
  )
  is_rich_text    on: :statement

  set_custom_fields :event_summary, :event_description, :event_location

  scope :latest, -> { where(latest: true) }
  scope :dangling, -> { joins('left join polls on polls.id = poll_id').where('polls.id is null') }
  scope :in_organisation, -> (group) { joins(:poll).where('polls.group_id': group.id_and_subgroup_ids) }
  belongs_to :poll, required: true
  belongs_to :poll_option, required: false
  belongs_to :author, class_name: 'User', required: true
  has_many :stances, through: :poll
  has_many :documents, as: :model, dependent: :destroy

  %w(
    title poll_type dates_as_options group group_id discussion discussion_id
    locale mailer members admins guest_voters discarded? tags
  ).each { |message| delegate message, to: :poll }

  is_mentionable on: :statement
  is_translatable on: :statement

  has_paper_trail only: [:statement, :statement_format, :author_id, :review_on]
  define_counter_cache(:versions_count) { |d| d.versions.count }
  validates :statement, presence: true, length: { maximum: Rails.application.secrets.max_message_length }
  validate :has_valid_poll_option

  scope :review_due_not_published, -> (due_date) do
    where(review_on: due_date).where("NOT EXISTS (
              SELECT 1 FROM events
              WHERE events.eventable_id   = outcomes.id AND
                    events.eventable_type = 'Outcome' AND
                    events.kind           = 'outcome_review_due')")
  end

  def author_name
    author.name
  end

  def user_id
    author_id
  end

  def body_format
    statement_format
  end

  def parent_event
    poll.created_event
  end

  def attendee_emails
     self.stances.joins(:participant).joins(:stance_choices)
    .where("stance_choices.poll_option_id": self.poll_option_id)
    .pluck(:"users.email").flatten.compact.uniq
  end

  def calendar_invite
    return nil unless self.poll_option && self.dates_as_options
    CalendarInvite.new(self).to_ical
  end

  def has_valid_poll_option
    return if !self.poll_option_id || poll.poll_option_ids.include?(self.poll_option_id)
    errors.add(:poll_option_id, I18n.t(:"outcome.error.invalid_poll_option"))
  end
end
