class Stance < ApplicationRecord
  include CustomCounterCache::Model
  include HasMentions
  include Reactable
  include HasEvents
  include HasCreatedEvent
  include HasVolume
  include Searchable

  extend HasTokens
  initialized_with_token :token

  def self.pg_search_insert_statement(id: nil, author_id: nil, discussion_id: nil, poll_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', stances.reason, users.name), E'<[^>]+>', '', 'gi')"
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
      SELECT 'Stance' AS searchable_type,
        stances.id AS searchable_id,
        stances.poll_id AS poll_id,
        polls.group_id as group_id,
        polls.discussion_id AS discussion_id,
        stances.participant_id AS author_id,
        stances.cast_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM stances
        LEFT JOIN users ON users.id = stances.participant_id
        LEFT JOIN polls ON polls.id = stances.poll_id
      WHERE polls.discarded_at IS NULL
        AND stances.cast_at IS NOT null
        AND NOT (polls.anonymous = TRUE AND polls.closed_at IS NULL)
        AND NOT (polls.hide_results = 2 AND polls.closed_at IS NULL)
        #{id ? " AND stances.id = #{id.to_i} LIMIT 1" : ''}
        #{author_id ? " AND stances.participant_id = #{author_id.to_i}" : ''}
        #{discussion_id ? " AND polls.discussion_id = #{discussion_id.to_i}" : ''}
        #{poll_id ? " AND stances.poll_id = #{poll_id.to_i}" : ''}
    SQL
  end

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']
  include Translatable
  is_translatable on: :reason
  is_mentionable  on: :reason
  include HasRichText

  is_rich_text on: :reason

  belongs_to :poll, required: true
  belongs_to :inviter, class_name: 'User'

  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  has_paper_trail only: [:reason, :option_scores, :revoked_at, :revoker_id, :inviter_id, :attachments]

  accepts_nested_attributes_for :stance_choices

  belongs_to :participant, class_name: 'User', required: true

  alias user participant
  alias author participant

  scope :dangling, -> { joins('left join polls on polls.id = poll_id').where('polls.id is null') }
  scope :latest, -> { where(latest: true, revoked_at: nil) }
  scope :guests, -> { where(guest: true) }
  scope :admins, -> { where(admin: true) }
  scope :newest_first, -> { order("cast_at DESC NULLS LAST") }
  scope :undecided_first, -> { order("cast_at DESC NULLS FIRST") }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last, -> { joins(:poll_options).order('poll_options.priority DESC') }
  scope :with_reason, -> { where("reason IS NOT NULL AND reason != '' AND reason != '<p></p>'") }
  scope :in_organisation, ->(group) { joins(:poll).where("polls.group_id": group.id_and_subgroup_ids) }
  scope :decided, -> { where("stances.cast_at IS NOT NULL") }
  scope :undecided, -> { where("stances.cast_at IS NULL") }
  scope :revoked, -> { where("revoked_at IS NOT NULL") }
  scope :guests, -> { where("inviter_id is not null") }
  scope :none_of_the_above, -> { where(none_of_the_above: true) }

  scope :redeemable, -> { latest.guests.undecided.where('stances.accepted_at IS NULL') }
  scope :redeemable_by,  -> (user_id) {
    redeemable.joins(:participant).where("stances.participant_id = ? or users.email_verified = false", user_id)
  }

  validate :valid_minimum_stance_choices
  validate :valid_maximum_stance_choices
  validate :valid_max_score
  validate :valid_min_score
  validate :valid_dots_per_person
  validate :valid_reason_length
  validate :valid_reason_required
  validate :valid_require_all_choices
  validate :valid_none_of_the_above
  validate :poll_options_must_match_stance_poll

  %w[group mailer group_id discussion_id discussion members voters title tags].each do |message|
    delegate(message, to: :poll)
  end

  before_save :assign_option_scores
  after_save :update_versions_count!

  def build_replacement
    Stance.new(
      poll_id: poll_id,
      participant_id: participant_id,
      inviter_id: inviter_id,
      reason_format: reason_format,
      latest: true
    )
  end

  def create_missing_created_event!
    events.create(
      kind: created_event_kind,
      user_id: (poll.anonymous? ? nil: author_id),
      created_at: created_at,
      discussion_id: (add_to_discussion? ? poll.discussion_id : nil)
    )
  end

  def author_name
    participant&.name
  end

  def assign_option_scores
    self.option_scores = build_option_scores
  end

  def build_option_scores
    stance_choices.map { |sc| [sc.poll_option_id.to_s, sc.score] }.to_h
  end

  def update_option_scores!
    update_columns(option_scores: assign_option_scores)
  end

  def update_versions_count!
    update_columns(versions_count: versions.count)
  end

  def author_id
    participant_id
  end

  def user_id
    participant_id
  end

  def locale
    author&.locale || group&.locale || poll.author.locale
  end

  def add_to_discussion?
    poll.discussion_id &&
    poll.hide_results != 'until_closed' &&
    !body_is_blank? &&
    !Event.where(eventable: self,
                 discussion_id: poll.discussion_id,
                 kind: ['stance_created', 'stance_updated']).exists?
  end

  def body
    reason
  end

  def body_format
    reason_format
  end

  def parent_event
    poll.created_event
  end

  def discarded?
    false
  end

  def choice=(choice)
    self.cast_at ||= Time.zone.now
    if choice.kind_of?(Hash)
      self.stance_choices_attributes = poll.poll_options.where(name: choice.keys).map do |option|
        {poll_option_id: option.id,
         score: choice[option.name]}
      end
    else
      options = poll.poll_options.where(name: choice)
      self.stance_choices_attributes = options.map do |option|
        {poll_option_id: option.id}
      end
    end
  end

  def participant
    (!participant_id || poll.anonymous?) ? AnonymousUser.new : super()
  end

  def real_participant
    User.find_by(id: participant_id)
  end

  def score_for(option)
    option_scores[option.id] || 0
  end

  private

  def poll_options_must_match_stance_poll
    invalid_choices = stance_choices.reject do |sc|
      sc.poll_option.poll_id == poll_id || !sc.persisted? && sc.poll_option.poll_id.nil?
    end

    if invalid_choices.any?
      errors.add(:base, "StanceChoices contain poll_options from different polls")
      Sentry.capture_message(
        "Invalid Stance: mismatched poll_options",
        level: :error,
        extra: {
          stance_id: id,
          poll_id: poll_id,
          invalid_choice_ids: invalid_choices.map(&:id),
          invalid_poll_ids: invalid_choices.map { |sc| sc.poll_option&.poll_id }
        }
      )
    end
  end

  def valid_none_of_the_above
    return if !cast_at
    return unless none_of_the_above
    errors.add(:none_of_the_above, "none_of_the_above not permitted for this poll") unless poll.show_none_of_the_above
    errors.add(:none_of_the_above, "you cant choose options pluss none_of_the_above") if stance_choices.any?
  end

  def valid_min_score
    return if !cast_at
    return if none_of_the_above
    return unless poll.validate_min_score
    return if (stance_choices.map(&:score).min || 0) >= poll.min_score

    errors.add(:stance_choices, "min_score validation failure")
  end

  def valid_max_score
    return if !cast_at
    return if none_of_the_above
    return unless poll.validate_max_score
    return if (stance_choices.map(&:score).max || 0) <= poll.max_score
    errors.add(:stance_choices, "max_score validation failure")
  end

  def valid_dots_per_person
    return if !cast_at
    return if none_of_the_above
    return unless poll.validate_dots_per_person
    return if stance_choices.map(&:score).sum <= poll.dots_per_person.to_i

    errors.add(:dots_per_person, "Too many dots")
  end

  def valid_minimum_stance_choices
    return if !cast_at
    return if none_of_the_above
    return unless poll.validate_minimum_stance_choices
    return if stance_choices.length >= poll.minimum_stance_choices

    errors.add(:stance_choices, "too few stance choices")
  end

  def valid_maximum_stance_choices
    return if !cast_at
    return if none_of_the_above
    return unless poll.validate_maximum_stance_choices
    return if stance_choices.length <= poll.maximum_stance_choices

    errors.add(:stance_choices, "too many stance choices")
  end

  def valid_require_all_choices
    return if !cast_at
    return if none_of_the_above
    return unless poll.require_all_choices
    return if poll.poll_options.length == 0
    return if stance_choices.length == poll.poll_options.length

    errors.add(:stance_choices, "require_all_stance_choices")
  end

  def valid_reason_length
    return if !cast_at
    return if !poll.limit_reason_length
    return if reason_visible_text.length < 501

    errors.add(:reason, I18n.t(:"poll_common.too_long"))
  end

  def valid_reason_required
    return if !cast_at
    return if poll.stance_reason_required != "required"
    return if reason_visible_text.length > 5

    errors.add(:reason, I18n.t(:"poll_common_form.stance_reason_is_required"))
  end
end
