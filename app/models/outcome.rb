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
  include Searchable
  
  def self.pg_search_insert_statement(id: nil, author_id: nil, discussion_id: nil, poll_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', outcomes.statement, users.name), E'<[^>]+>', '', 'gi')"
    <<~SQL.squish
      INSERT INTO pg_search_documents (
        searchable_type,
        searchable_id,
        poll_id,
        group_id,
        discussion_id,
        author_id,
        authored_at,
        content,
        ts_content,
        created_at,
        updated_at)
      SELECT 'Outcome' AS searchable_type,
        outcomes.id AS searchable_id,
        outcomes.poll_id AS poll_id,
        polls.group_id as group_id,
        polls.discussion_id AS discussion_id,
        outcomes.author_id AS author_id,
        outcomes.created_at as authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM outcomes
        LEFT JOIN users ON users.id = outcomes.author_id
        LEFT JOIN polls ON polls.id = outcomes.poll_id
      WHERE polls.discarded_at IS NULL 
        #{id ? " AND outcomes.id = #{id.to_s.to_i} LIMIT 1" : ""}
        #{author_id ? " AND outcomes.author_id = #{author_id.to_s.to_i}" : ""}
        #{discussion_id ? " AND polls.discussion_id = #{discussion_id.to_s.to_i}" : ""}
        #{poll_id ? " AND outcomes.poll_id = #{poll_id.to_s.to_i}" : ""}
    SQL
  end
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
    locale mailer members admins discarded? tags
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

  def body
    statement
  end

  def body=(val)
    self.statement = val
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
