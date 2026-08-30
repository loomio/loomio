class Poll < ApplicationRecord
  PARTICIPATION_STATUS_VOTES_MIN = 3

  extend  HasCustomFields
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include HasTopicItems
  include HasNotifications
  include HasMentions
  include SelfReferencing
  include Reactable
  include Bookmarkable
  include HasRichText
  include Discard::Model
  include Searchable

  def self.pg_search_insert_statement(id: nil, author_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', polls.title, polls.details, users.name), E'<[^>]+>', '', 'gi')"
    <<~SQL.squish
      INSERT INTO pg_search_documents (
        searchable_type,
        searchable_id,
        poll_id,
        group_id,
        discussion_id,
        topic_id,
        tags,
        author_id,
        authored_at,
        content,
        ts_content,
        created_at,
        updated_at)
      SELECT 'Poll' AS searchable_type,
        polls.id AS searchable_id,
        polls.id AS poll_id,
        t.group_id as group_id,
        CASE WHEN t.topicable_type = 'Discussion' THEN t.topicable_id ELSE NULL END AS discussion_id,
        polls.topic_id AS topic_id,
        t.tags AS tags,
        polls.author_id AS author_id,
        polls.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM polls
        LEFT JOIN topics t ON t.id = polls.topic_id
        LEFT JOIN users ON users.id = polls.author_id
      WHERE polls.discarded_at IS NULL
        #{id ? " AND polls.id = #{id.to_i} LIMIT 1" : ""}
        #{author_id ? " AND polls.author_id = #{author_id.to_i}" : ""}
    SQL
  end

  is_rich_text on: :details

  extend NoSpam
  no_spam_for :title, :details

  set_custom_fields :meeting_duration,
                    :time_zone,
                    :can_respond_maybe

  TEMPLATE_DEFAULT_FIELDS = %w[
    poll_option_name_format
    chart_type
    default_duration_in_days
  ].freeze

  BALLOT_DEFAULT_FIELDS = %w[
    max_score
    min_score
    dots_per_person
  ].freeze

  TEMPLATE_DEFAULT_FIELDS.each do |field|
    define_method field, -> {
      self[field] || self[:custom_fields][field] || AppConfig.poll_types.dig(self.poll_type, 'defaults', field)
    }

    define_method :"#{field}=", ->(value) {
      self[:custom_fields].delete(field)
      if value == AppConfig.poll_types.dig(self.poll_type, 'defaults', field)
        self[field] = nil
      else
        self[field] = value
      end
      value
    }
  end

  BALLOT_DEFAULT_FIELDS.each do |field|
    define_method field, -> {
      self[field] || AppConfig.poll_types.dig(self.poll_type, 'defaults', field)
    }

    define_method :"#{field}=", ->(value) {
      if value == AppConfig.poll_types.dig(self.poll_type, 'defaults', field)
        self[field] = nil
      else
        self[field] = value
      end
      value
    }
  end

  TEMPLATE_VALUES = %w(has_option_icon
                       ballot_rule
                       order_results_by
                       prevent_anonymous
                       vote_method
                       material_icon
                       require_all_choices
                       has_options).freeze

  TEMPLATE_VALUES.each do |field|
    define_method field, -> { AppConfig.poll_types.dig(self.poll_type, field) }
  end

  def author
    super || LoggedOutUser.new(name: I18n.t('profile_page.deleted_account'))
  end

  def title_model
    self
  end

  def poll_template
    return PollTemplate.find_by(id: poll_template_id) if poll_template_id
    return PollTemplateService.default_templates.find {|pt| pt.key == poll_template_key } if poll_template_key
    return nil
  end

  def create_missing_created_topic_item!
    self.topic_items.create(
      kind: created_topic_item_kind,
      user_id: author_id,
      created_at: created_at,
      topic: topic)
  end

  def minimum_stance_choices
    if require_all_choices
      poll_options.length
    else
      self[:minimum_stance_choices] ||
      AppConfig.poll_types.dig(self.poll_type, 'defaults', 'minimum_stance_choices') ||
      0
    end
  end

  def maximum_stance_choices
    self[:maximum_stance_choices] ||
    AppConfig.poll_types.dig(self.poll_type, 'defaults', 'maximum_stance_choices') ||
    poll_options.length
  end

  include Translatable
  is_translatable on: [:title, :details]
  is_mentionable on: :details

  belongs_to :author, class_name: "User"
  has_many   :outcomes, dependent: :destroy
  has_one    :current_outcome, -> { where(latest: true) }, class_name: 'Outcome'

  belongs_to :topic, autosave: true

  enum :notify_on_closing_soon, {nobody: 0, author: 1, undecided_voters: 2, voters: 3}
  enum :hide_results, {off: 0, until_vote: 1, until_closed: 2}
  enum :stance_reason_required, {
    disabled: 0,
    optional: 1,
    required: 2,
    required_for_disagree_or_block: 3,
    required_for_block: 4
  }
  enum :voting_system, {stance: 0, anonymous_ballot: 1}

  has_many :stances, dependent: :destroy
  has_many :stance_choices, through: :stances
  has_many :stance_voters, -> { merge(Stance.latest) }, through: :stances, source: :participant
  has_many :stance_undecided_voters, -> { merge(Stance.latest.undecided) }, through: :stances, source: :participant
  has_many :stance_decided_voters, -> { merge(Stance.latest.decided) }, through: :stances, source: :participant
  has_many :none_of_the_above_voters, -> { merge(Stance.latest.none_of_the_above) }, through: :stances, source: :participant

  has_many :anonymous_poll_voters, dependent: :destroy
  has_many :anonymous_ballots, dependent: :destroy
  has_many :anonymous_ballot_choices, through: :anonymous_ballots
  has_many :legacy_anonymous_vote_reasons, through: :anonymous_ballots

  has_many :poll_options, -> { order('priority') }, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :poll_options, allow_destroy: true

  has_many :stance_receipts, dependent: :destroy

  scope :active, -> { kept.where('polls.closed_at': nil).where('polls.opened_at IS NOT NULL') }
  scope :template, -> { kept.where('polls.template': true) }
  scope :closed, -> { kept.where("polls.closed_at IS NOT NULL") }
  scope :recent, -> { kept.where("polls.opened_at IS NOT NULL").where("polls.closed_at IS NULL or polls.closed_at > ?", 7.days.ago) }
  scope :search_for, ->(fragment) { kept.where("polls.title ilike :fragment", fragment: "%#{fragment}%") }
  scope :lapsed_but_not_closed, -> { active.where("polls.closing_at < ?", Time.now) }
  scope :active_or_closed_after, ->(since) { kept.where("polls.closed_at IS NULL OR polls.closed_at > ?", since) }
  scope :closing_soon_not_published, ->(timeframe) do
     active
    .distinct
    .where(closing_at: timeframe)
    .where("NOT EXISTS (SELECT 1 FROM notifications
                WHERE notifications.created_at   >= polls.closing_at - INTERVAL '25 hours' AND
                      notifications.subject_id   = polls.id AND
                      notifications.subject_type = 'Poll' AND
                      notifications.kind         = 'poll_closing_soon')")
  end

  validates :poll_type, inclusion: { in: AppConfig.poll_types.keys }
  validates :details, length: {maximum: AppConfig.app_features[:max_message_length] }

  before_validation :clamp_minimum_stance_choices
  normalizes :quorum_pct, with: ->(v) { v.nil? ? nil : [ [ v, 0 ].max, 100 ].min }
  normalizes :closing_at, :opening_at, with: ->(v) { v&.beginning_of_hour }
  validate :closes_in_future
  validate :opening_at_before_closing_at
  validate :cannot_deanonymize
  validate :cannot_reveal_results_early
  validate :anonymous_matches_voting_system
  validate :detached_anonymous_invariants
  validate :voting_system_cannot_change_after_opening
  validate :detached_configuration_cannot_change_after_ballot
  validate :score_bounds_are_valid, if: :score_bounds_validation_required?
  validate :title_if_not_discarded

  alias_method :user, :author

  has_paper_trail only: [
    :author_id,
    :title,
    :details,
    :details_format,
    :closing_at,
    :closed_at,
    :anonymous,
    :discarded_at,
    :discarded_by,
    :voter_can_add_options,
    :specified_voters_only,
    :stance_reason_required,
    :tags,
    :notify_on_closing_soon,
    :notify_on_open,
    :poll_option_names,
    :hide_results,
    :attachments]

  after_commit :update_group_counter_caches
  def update_group_counter_caches
    return unless (g = topic.group) && g.id
    return if g.destroyed? # group teardown cascaded to this poll — nothing to recount
    g.update_polls_count
    g.update_closed_polls_count
  end

  delegate :locale, to: :author
  delegate :name, to: :author, prefix: true
  delegate :guests, :guest_ids, :add_guest!, :add_admin!, :admins, :members, :group_id, :group, to: :topic

  def has_score_icons
    vote_method == "time_poll"
  end

  def has_variable_score
    !(min_score == max_score)
  end

  def is_single_choice?
    minimum_stance_choices == 1 && maximum_stance_choices == 1
  end

  def results_include_undecided
    poll_type != "meeting"
  end

  def dates_as_options
    poll_option_name_format == 'iso8601'
  end

  def chart_column
    case poll_type
    when 'count' then (agree_target ? 'target_percent' : 'voter_percent')
    when 'check', 'proposal' then 'score_percent'
    else
      'max_score_percent'
    end
  end

  def can_respond_maybe
    self[:custom_fields].fetch('can_respond_maybe', false)
  end

  def result_columns
    case poll_type
    when 'proposal'
      %w[chart name votes votes_cast_percent voter_percent voters]
    when 'check'
      %w[chart name voter_percent voter_count voters]
    when 'count'
      if agree_target
        %w[chart name target_percent voter_count voters]
      else
        %w[chart name voter_count voters]
      end
    when 'ranked_choice'
      %w[chart name rank score_percent score average voter_count]
    when 'stv'
      %w[chart name stv_status voter_count]
    when 'dot_vote'
      %w[chart name score_percent score average voter_count]
    when 'score'
      %w[chart name score average voter_count]
    when 'poll'
      %w[chart name score_percent voter_count voters]
    when 'meeting'
      %w[chart name score voters]
    else
      []
    end
  end

  def results
    PollService.calculate_results(self, self.poll_options)
  end

  def stv_results
    custom_fields['stv_results']
  end

  def stv_results=(value)
    custom_fields['stv_results'] = value
  end

  def user_id
    author_id
  end

  def decided_voters_count
    voters_count - undecided_voters_count
  end

  def cast_stances_pct
    return 0 if voters_count == 0
    ((decided_voters_count.to_f / voters_count) * 100).to_i
  end

  # General-purpose voter relations must not reveal participation identities for
  # detached anonymous ballots. Callers that intentionally need the named
  # electorate, such as authorization and reminder delivery, use unmasked_*.
  def voters
    detached_anonymous? ? User.none : stance_voters
  end

  def voter_ids
    voters.ids
  end

  def undecided_voters
    detached_anonymous? ? User.none : stance_undecided_voters
  end

  def decided_voters
    detached_anonymous? ? User.none : stance_decided_voters
  end

  def unmasked_voters
    return User.where(id: anonymous_poll_voters.select(:voter_id)) if detached_anonymous?

    voters
  end

  def unmasked_undecided_voters
    return User.where(id: anonymous_poll_voters.where(ballot_submitted: false).select(:voter_id)) if detached_anonymous?

    undecided_voters
  end

  def unmasked_decided_voters
    return User.where(id: anonymous_poll_voters.where(ballot_submitted: true).select(:voter_id)) if detached_anonymous?

    decided_voters
  end

  def detached_anonymous?
    anonymous? && anonymous_ballot?
  end

  def participation_status_visible?
    return true unless anonymous?

    anonymous_ballots.offset(PARTICIPATION_STATUS_VOTES_MIN - 1).exists?
  end

  def body
    details
  end

  def body=(val)
    self.details = val
  end

  def body_format
    details_format
  end

  def time_zone
    custom_fields.fetch('time_zone', author.time_zone)
  end

  def quorum_count
    (quorum_pct.to_f/100 * voters_count).ceil
  end

  def quorum_reached?
    quorum_pct && quorum_count <= voters_count
  end

  def quorum_votes_required
    return 0 if quorum_pct.nil?
    (((quorum_pct.to_f - cast_stances_pct.to_f)/100) * voters_count).ceil
  end

  def show_results?(voted: false)
    !!case hide_results
      when 'until_closed'
        closed_at
      else
        true
      end
  end

  # this should not be run on anonymous polls
  def reset_latest_stances!
    self.transaction do
      self.stances.update_all(latest: false)
      Stance.where("id IN
        (SELECT DISTINCT ON (participant_id) id
         FROM stances
         WHERE poll_id = #{id}
         ORDER BY participant_id, created_at DESC)").update_all(latest: true)
    end
  end

  def total_score
    stance_counts.sum
  end

  def update_counts!
    poll_options.reload.each(&:update_counts!)
    if detached_anonymous?
      return update_columns(
        stance_counts: poll_options.map(&:total_score),
        voters_count: anonymous_poll_voters.count,
        undecided_voters_count: anonymous_poll_voters.where(ballot_submitted: false).count,
        none_of_the_above_count: anonymous_ballots.where(none_of_the_above: true).count,
        versions_count: versions.count
      )
    end

    update_columns(
      stance_counts: poll_options.map(&:total_score), # should rename to option scores
      voters_count: stances.latest.count, # should rename to stances_count
      undecided_voters_count: stances.latest.undecided.count,
      none_of_the_above_count: stances.latest.decided.where(none_of_the_above: true).count,
      versions_count: versions.count
    )
  end

  def opened?
    !!opened_at
  end

  def active?
    kept? && (closing_at && closing_at > Time.now) && !closed_at && opened?
  end

  # A pending vote is current user state, not merely the absence of any stance.
  # Recheck access and electorate rules so stale notifications cannot disclose or
  # request action on polls the user can no longer see or participate in.
  def vote_needed_from?(user)
    return false unless active?
    return false unless user.can?(:show, self)
    return false unless user.can?(:vote_in, self)

    if detached_anonymous?
      anonymous_poll_voters.exists?(voter_id: user.id, ballot_submitted: false)
    else
      !stances.latest.decided.exists?(participant_id: user.id)
    end
  end

  def scheduled?
    opening_at.present? && !opened?
  end

  def wip?
    closing_at.nil?
  end

  def closed?
    !!closed_at
  end

  def poll_option_names
    poll_options.map(&:name)
  end

  def poll_option_names=(names)
    names    = Array(names)
    existing = Array(poll_options.pluck(:name))
    names = names.sort if poll_type == 'meeting'
    names.each_with_index do |name, priority|
      option = poll_options.find_or_initialize_by(name: name)
      option.priority = priority
      os = AppConfig.poll_types.dig(self.poll_type, 'common_poll_options') || []
      if params = os.find {|o| o['key'] == name }
        option.name = I18n.t(params['name_i18n'])
        option.icon = params['icon']
        option.meaning = I18n.t(params['meaning_i18n'])
        option.prompt = I18n.t(params['prompt_i18n'])
      end
    end
    removed = (existing - names)
    poll_options.each {|option| option.mark_for_destruction if removed.include?(option.name) }
    names
  end

  alias options= poll_option_names=
  alias options poll_option_names

  def is_new_version?
    !self.poll_options.map(&:persisted?).all? ||
    (['title', 'details', 'closing_at', 'opening_at'] & self.changes.keys).any?
  end

  def prioritise_poll_options!
    if self.poll_type == 'meeting'
      self.poll_options.sort {|a,b| a.name <=> b.name }.each_with_index {|o, i| o.priority = i }
    end
  end

  private

  def score_bounds_validation_required?
    new_record? || will_save_change_to_min_score? || will_save_change_to_max_score?
  end

  def score_bounds_are_valid
    score_min = Integer(min_score, exception: false)
    score_max = Integer(max_score, exception: false)

    errors.add(:min_score, :invalid) if min_score.present? && (score_min.nil? || score_min.negative?)
    errors.add(:max_score, :invalid) if max_score.present? && (score_max.nil? || score_max.negative?)
    errors.add(:max_score, :invalid) if score_min && score_max && score_max < score_min
  end

  def title_if_not_discarded
    if !discarded_at && title.to_s.empty?
      errors.add(:title, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end

  def cannot_deanonymize
    if anonymous_changed? && anonymous_was == true
      errors.add :anonymous, :cannot_deanonymize
    end
  end

  def cannot_reveal_results_early
    if hide_results_changed? && (hide_results_was == 'until_closed')
      errors.add :hide_results, :cannot_show_results_early
    end
  end

  def detached_anonymous_invariants
    return unless anonymous_ballot?

    errors.add(:anonymous, :invalid) unless anonymous?
    errors.add(:hide_results, :invalid) unless hide_results == "until_closed"
    errors.add(:stance_reason_required, :invalid) unless stance_reason_required == "disabled"
    errors.add(:notify_on_closing_soon, :invalid) unless notify_on_closing_soon == "undecided_voters"
  end

  def anonymous_matches_voting_system
    return if anonymous? == anonymous_ballot?

    errors.add(:voting_system, :invalid)
  end

  def voting_system_cannot_change_after_opening
    return unless will_save_change_to_voting_system?
    return unless voting_system_in_database && opened_at_in_database

    errors.add(:voting_system, :invalid)
  end

  def detached_configuration_cannot_change_after_ballot
    return unless detached_anonymous? && persisted? && anonymous_ballots.exists?

    protected_attributes = %w[
      anonymous voting_system hide_results stance_reason_required poll_type
      min_score max_score minimum_stance_choices maximum_stance_choices
      dots_per_person show_none_of_the_above stv_seats stv_method stv_quota
    ]
    if (changes_to_save.keys & protected_attributes).any?
      errors.add(:base, :anonymous_ballot_configuration_frozen)
    end
  end

  def closes_in_future
    return if closed_at
    return if closing_at.nil?
    return if closing_at > Time.zone.now
    errors.add(:closing_at, I18n.t(:"poll.error.must_be_in_the_future"))
  end

  def opening_at_before_closing_at
    return if opening_at.nil?
    if closing_at.nil?
      errors.add(:closing_at, I18n.t(:"poll.error.must_be_in_the_future"))
      return
    end
    return if opening_at < closing_at
    errors.add(:opening_at, I18n.t(:"poll.error.opening_at_before_closing_at"))
  end

  def clamp_minimum_stance_choices
    return if self[:minimum_stance_choices].nil?
    if self[:minimum_stance_choices] > poll_options.length
      self.minimum_stance_choices = poll_options.length
    end
  end
end
