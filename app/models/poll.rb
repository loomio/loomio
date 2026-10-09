class Poll < ApplicationRecord
  include HasCountChanges
  include LocksTopicsForCounts
  PARTICIPATION_STATUS_VOTES_MIN = 3
  RESULT_VOTER_IDS_MAX = 50

  extend  HasCustomFields
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
                       prevent_weighted_voting
                       vote_method
                       material_icon
                       require_all_choices
                       has_options).freeze

  TEMPLATE_VALUES.each do |field|
    define_method field, -> { AppConfig.poll_types.dig(self.poll_type, field) }
  end

  # Polls and poll templates share this rule. Anonymous ballots do not record
  # who voted, so they cannot carry weights, and poll_types.yml marks the
  # voting methods that do not support weighted totals.
  def self.weighted_voting_available?(poll_type:, anonymous:)
    !anonymous && !AppConfig.poll_types.dig(poll_type, 'prevent_weighted_voting')
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
      poll_option_count
    else
      self[:minimum_stance_choices] ||
      AppConfig.poll_types.dig(self.poll_type, 'defaults', 'minimum_stance_choices') ||
      0
    end
  end

  # Types without a configured maximum offer no setting for it, so their limit
  # always follows the options. Clients echo the serialized value back on edit,
  # and a stored copy would go stale when options are added.
  def maximum_stance_choices
    maximum_stance_choices_default = AppConfig.poll_types.dig(self.poll_type, 'defaults', 'maximum_stance_choices')
    if require_all_choices || maximum_stance_choices_default.nil?
      poll_option_count
    else
      self[:maximum_stance_choices] || maximum_stance_choices_default
    end
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


  scope :active, -> { kept.where('polls.closed_at': nil).where('polls.opened_at IS NOT NULL') }
  scope :template, -> { kept.where('polls.template': true) }
  scope :closed, -> { kept.where("polls.closed_at IS NOT NULL") }
  scope :recent, -> { kept.where("polls.opened_at IS NOT NULL").where("polls.closed_at IS NULL or polls.closed_at > ?", 7.days.ago) }
  scope :search_for, ->(fragment) { kept.where("polls.title ilike :fragment", fragment: "%#{fragment}%") }
  scope :lapsed_but_not_closed, -> { active.where("polls.closing_at < ?", Time.now) }
  scope :active_or_closed_after, ->(since) { kept.where("polls.closed_at IS NULL OR polls.closed_at > ?", since) }
  scope :closing_soon_not_published, ->(timeframe) do
     active
    .where(topic_id: Topic.left_joins(:group).group_enabled.select(:id))
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
  validate :anonymity_cannot_change
  validate :cannot_reveal_results_early
  validate :anonymous_invariants
  validate :anonymous_configuration_cannot_change_after_ballot
  validate :weighted_voting_available
  validate :stv_settings_are_valid, if: :stv_settings_validation_required?
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
    :specified_voters_only,
    :stance_reason_required,
    :tags,
    :notify_on_closing_soon,
    :notify_on_open,
    :weighted_voting,
    :poll_option_names,
    :hide_results,
    :attachments]

  after_save :update_poll_counts, if: -> { saved_changes.keys.intersect?(%w[id topic_id opened_at closed_at discarded_at]) }
  after_destroy :update_poll_counts
  around_create :with_topics_write_lock_for_counts, prepend: true
  around_update :with_topics_write_lock_for_counts, if: -> { changes.keys.intersect?(%w[topic_id opened_at closed_at discarded_at]) }, prepend: true
  around_destroy :with_topics_write_lock_for_counts, prepend: true
  after_save_commit -> { ReindexPollWorker.perform_later(id) }
  after_update :synchronize_stance_weights_after_vote_weights_change

  # Switching vote weights resets issued stances, including cast votes, so
  # stored weights and poll results reflect the current voting mode.
  def synchronize_stance_weights_after_vote_weights_change
    return unless saved_change_to_weighted_voting?

    unless weighted_voting?
      stances.where.not(weight: 1).update_all(weight: 1)
      return
    end

    reset_stance_weights_from_memberships!
  end

  # Copy current group defaults into issued votes in one statement. Voters
  # without an active membership, including direct-poll voters, receive 1.
  def reset_stance_weights_from_memberships!
    return stances.latest.update_all(weight: 1) unless group_id

    member_weight = Membership.active.where(group_id: group_id)
      .where('memberships.user_id = stances.participant_id')
      .select(:weight)
      .limit(1)
    stances.latest.update_all(weight: Arel.sql("COALESCE((#{member_weight.to_sql}), 1)"))
  end

  def update_poll_counts
    before, after = count_states
    RecordCounts.update!(Group, :polls_count,
      before: counted_group_id(before), after: counted_group_id(after), records: [group])
    RecordCounts.update!(Topic, :active_polls_count,
      before: counted_active_topic_id(before), after: counted_active_topic_id(after), records: [topic])
  end

  def counted_group_id(state)
    return unless state

    # Closed/discarded polls still count toward the group's total. During
    # mutual topic/poll autosave, use the loaded group until the topic has an ID.
    state['topic_id'] ? @count_group_ids.fetch(state['topic_id']) : group_id
  end

  def counted_active_topic_id(state)
    return unless state && state['discarded_at'].nil? && state['closed_at'].nil? && state['opened_at'].present?

    state['topic_id']
  end
  private :update_poll_counts, :counted_group_id, :counted_active_topic_id

  # Operations that change a poll and its timeline must lock the topic first.
  # A branch move can change the owner while we wait; retry from a savepoint
  # so the old topic lock is released before acquiring the new owner's lock.
  def with_topic_lock
    owner_id = topic_id_in_database
    destination_id = topic_id
    destination_changed = will_save_change_to_topic_id?
    loop do
      completed = false
      result = Topic.where(id: [owner_id, destination_changed ? destination_id : owner_id])
                    .order(:id).with_write_lock(requires_new: true) do |topics|
        owners = topics.index_by(&:id)
        current_poll = self.class.find(id)
        if current_poll.topic_id != owner_id
          owner_id = current_poll.topic_id
          raise ActiveRecord::Rollback
        end

        # Refresh the stored source without losing an intentional destination.
        self.topic_id = owner_id
        clear_attribute_change(:topic_id)
        self.topic_id = destination_id if destination_changed
        association(:topic).target = owners.fetch(topic_id)
        current_poll.association(:topic).target = owners.fetch(owner_id)
        value = yield current_poll
        completed = true
        value
      end
      return result if completed
    end
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

  # Result headings keep master's labels. A column whose value includes vote
  # weights gets a "Weighted" label instead, in the unit voters give: votes for
  # one-point methods, points otherwise.
  RESULT_HEADING_KEYS = {
    'name' => 'common.option',
    'target_percent' => 'poll_count_form.pct_of_target',
    'score_percent' => 'poll_ranked_choice_form.pct_of_points',
    'votes_cast_percent' => 'poll_ranked_choice_form.pct_of_votes_cast',
    'voter_percent' => 'poll_ranked_choice_form.pct_of_voters',
    'rank' => 'poll_ranked_choice_form.rank',
    'score' => 'poll_ranked_choice_form.points',
    'unweighted_score' => 'poll_ranked_choice_form.points',
    'average' => 'poll_ranked_choice_form.mean',
    'stv_status' => 'poll_common.status',
    'voter_count' => 'membership_card.voters',
    'votes' => 'poll_common.votes'
  }.freeze

  WEIGHTED_VOTES_HEADING_KEYS = {
    'score' => 'poll_common.weighted_votes',
    'score_percent' => 'poll_common.pct_of_weighted_votes',
    'votes_cast_percent' => 'poll_common.pct_of_weighted_votes'
  }.freeze

  WEIGHTED_POINTS_HEADING_KEYS = {
    'score' => 'poll_common.weighted_points',
    'score_percent' => 'poll_common.pct_of_weighted_points',
    'votes_cast_percent' => 'poll_common.pct_of_weighted_points',
    'average' => 'poll_common.weighted_mean'
  }.freeze

  def result_columns
    weighted_voting? ? weighted_result_columns : unweighted_result_columns
  end

  def unweighted_result_columns
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

  # Weighted results list the counts first, plain before weighted, then the
  # percentages. Poll types without weighting keep their usual columns.
  def weighted_result_columns
    case poll_type
    when 'proposal'
      %w[chart name votes score voter_percent votes_cast_percent voters]
    when 'check'
      %w[chart name voter_count score voter_percent voters]
    when 'count'
      if agree_target
        %w[chart name voter_count score target_percent voters]
      else
        %w[chart name voter_count score voters]
      end
    when 'poll'
      %w[chart name voter_count score score_percent voters]
    when 'ranked_choice'
      %w[chart name rank unweighted_score score score_percent average voter_count]
    when 'dot_vote'
      %w[chart name unweighted_score score score_percent average voter_count]
    when 'score'
      %w[chart name unweighted_score score average voter_count]
    else
      unweighted_result_columns
    end
  end

  def result_heading_key(column)
    weighted_keys = if !weighted_voting? then {}
    elsif one_point_choices? then WEIGHTED_VOTES_HEADING_KEYS
    else WEIGHTED_POINTS_HEADING_KEYS
    end
    weighted_keys.fetch(column) { RESULT_HEADING_KEYS.fetch(column) }
  end

  def result_heading_keys
    result_columns.excluding('chart', 'voters').index_with { |column| result_heading_key(column) }
  end

  def member_vote_weights_by_user_id(user_ids)
    return {} unless group_id

    Membership.active.where(group_id: group_id, user_id: user_ids).pluck(:user_id, :weight).to_h
  end

  def one_point_choices?
    min_score == 1 && max_score == 1
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
  # anonymous ballots. Callers that intentionally need the named
  # electorate, such as authorization and reminder delivery, use unmasked_*.
  def voters
    anonymous? ? User.none : stance_voters
  end

  def voter_ids
    voters.ids
  end

  def undecided_voters
    anonymous? ? User.none : stance_undecided_voters
  end

  def decided_voters
    anonymous? ? User.none : stance_decided_voters
  end

  def unmasked_voters
    return User.where(id: anonymous_poll_voters.select(:voter_id)) if anonymous?

    voters
  end

  def unmasked_undecided_voters
    return User.where(id: anonymous_poll_voters.where(ballot_submitted: false).select(:voter_id)) if anonymous?

    undecided_voters
  end

  def unmasked_decided_voters
    return User.where(id: anonymous_poll_voters.where(ballot_submitted: true).select(:voter_id)) if anonymous?

    decided_voters
  end

  # Who voted in an anonymous poll stays hidden until enough people have voted
  # that the list says little about any one person: the quorum when the poll
  # has one, otherwise half the electorate, and never fewer than three votes.
  def participation_status_votes_required
    votes_required = quorum_pct ? quorum_count : (voters_count / 2.0).ceil
    [votes_required, PARTICIPATION_STATUS_VOTES_MIN].max
  end

  def participation_status_visible?
    return true unless anonymous?

    anonymous_ballots.offset(participation_status_votes_required - 1).exists?
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

  # Result data for until-vote polls may be sent to the client, which owns that
  # presentation rule. Until-closed polls remain protected at the backend.
  def results_available?
    hide_results != 'until_closed' || closed_at.present?
  end

  # Server-rendered output must apply the recipient-specific until-vote rule.
  def results_visible?(voted: false)
    results_available? && (hide_results != 'until_vote' || closed_at.present? || voted)
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
    stance_counts.sum { |score| BigDecimal(score.to_s) }
  end

  def update_counts!
    poll_options.reload.each(&:update_counts!)
    if anonymous?
      return update_columns(
        stance_counts: poll_options.map { |option| option.total_score.to_f },
        voters_count: anonymous_poll_voters.count,
        undecided_voters_count: anonymous_poll_voters.where(ballot_submitted: false).count,
        none_of_the_above_count: anonymous_ballots.where(none_of_the_above: true).count,
        versions_count: versions.count
      )
    end

    update_columns(
      stance_counts: poll_options.map { |option| option.total_score.to_f }, # should rename to option scores
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

    if anonymous?
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

  # Anonymity is fixed when a poll is created: an anonymous poll records voters
  # and ballots separately from the start, and a named poll records stances.
  def anonymity_cannot_change
    return unless persisted? && will_save_change_to_anonymous?

    errors.add :anonymous, (anonymous_in_database ? :cannot_deanonymize : :invalid)
  end

  def cannot_reveal_results_early
    if hide_results_changed? && (hide_results_was == 'until_closed')
      errors.add :hide_results, :cannot_show_results_early
    end
  end

  def anonymous_invariants
    return unless anonymous?

    errors.add(:hide_results, :invalid) unless hide_results == "until_closed"
    errors.add(:stance_reason_required, :invalid) unless stance_reason_required == "disabled"
    errors.add(:notify_on_closing_soon, :invalid) unless notify_on_closing_soon == "undecided_voters"
  end

  def anonymous_configuration_cannot_change_after_ballot
    return unless anonymous? && persisted? && anonymous_ballots.exists?

    protected_attributes = %w[
      anonymous hide_results stance_reason_required poll_type
      min_score max_score minimum_stance_choices maximum_stance_choices
      dots_per_person show_none_of_the_above stv_seats stv_method stv_quota
    ]
    if (changes_to_save.keys & protected_attributes).any?
      errors.add(:base, :anonymous_ballot_configuration_frozen)
    end
  end

  def weighted_voting_available
    return unless weighted_voting?
    return if Poll.weighted_voting_available?(poll_type: poll_type, anonymous: anonymous?)

    errors.add(:weighted_voting, :invalid)
  end

  STV_METHODS = %w[scottish meek].freeze
  STV_QUOTAS = %w[droop hare].freeze

  # An STV count needs at least one seat and more candidates than seats, or
  # every candidate is simply elected. The counters fall back to defaults for
  # blank settings, so only reject values that are present and unsupported.
  def stv_settings_are_valid
    seats = stv_seats || 1
    errors.add(:stv_seats, :greater_than_or_equal_to, count: 1) if seats < 1
    errors.add(:stv_seats, :less_than, count: poll_option_count) if poll_option_count > 0 && seats >= poll_option_count
    errors.add(:stv_method, :inclusion) if stv_method.present? && !STV_METHODS.include?(stv_method)
    errors.add(:stv_quota, :inclusion) if stv_quota.present? && !STV_QUOTAS.include?(stv_quota)
  end

  # Validate when the settings or candidates change, so polls saved before
  # this validation existed can still be closed and counted.
  def stv_settings_validation_required?
    return false unless poll_type == 'stv'

    new_record? ||
      will_save_change_to_poll_type? ||
      will_save_change_to_stv_seats? ||
      will_save_change_to_stv_method? ||
      will_save_change_to_stv_quota? ||
      poll_options.any? { |option| option.new_record? || option.marked_for_destruction? }
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
    if self[:minimum_stance_choices] > poll_option_count
      self.minimum_stance_choices = poll_option_count
    end
  end

  def poll_option_count
    poll_options.count { |option| !option.marked_for_destruction? }
  end
end
