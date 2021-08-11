class Poll < ApplicationRecord
  extend  HasCustomFields
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include HasEvents
  include HasMentions
  include MessageChannel
  include SelfReferencing
  include HasMailer
  include Reactable
  include HasCreatedEvent
  include HasRichText
  include HasTags
  include Discard::Model

  is_rich_text    on: :details

  extend  NoSpam
  no_spam_for :title, :details

  set_custom_fields :meeting_duration,
                    :time_zone,
                    :dots_per_person,
                    :pending_emails,
                    :minimum_stance_choices,
                    :can_respond_maybe,
                    :deanonymize_after_close,
                    :max_score

  TEMPLATE_FIELDS = %w(material_icon translate_option_name can_vote_anonymously
                       can_add_options can_remove_options author_receives_outcome
                       must_have_options chart_type has_option_icons
                       has_variable_score voters_review_responses
                       dates_as_options required_custom_fields has_option_score_counts
                       require_stance_choices require_all_choices prevent_anonymous
                       poll_options_attributes experimental has_score_icons).freeze
  TEMPLATE_FIELDS.each do |field|
    define_method field, -> { AppConfig.poll_templates.dig(self.poll_type, field) }
  end

  include Translatable
  is_translatable on: [:title, :details]
  is_mentionable on: :details

  belongs_to :author, class_name: "User"
  has_many   :outcomes, dependent: :destroy
  has_one    :current_outcome, -> { where(latest: true) }, class_name: 'Outcome'

  belongs_to :discussion
  belongs_to :group, class_name: "Group"

  enum notify_on_closing_soon: {nobody: 0, author: 1, undecided_voters: 2, voters: 3}

  before_save :set_stances_in_discussion
  after_save :update_counts!

  has_many :stances, dependent: :destroy
  has_many :stance_choices, through: :stances
  has_many :voters,       -> { merge(Stance.latest) }, through: :stances, source: :participant
  has_many :admin_voters, -> { merge(Stance.latest.admin) }, through: :stances, source: :participant
  has_many :undecided_voters, -> { merge(Stance.latest.undecided) }, through: :stances, source: :participant
  has_many :decided_voters, -> { merge(Stance.latest.decided) }, through: :stances, source: :participant

  has_many :poll_options, -> { order('priority') }, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :poll_options, allow_destroy: true

  has_many :documents, as: :model, dependent: :destroy

  scope :active, -> { kept.where('polls.closed_at': nil) }
  scope :closed, -> { kept.where("polls.closed_at IS NOT NULL") }
  scope :recent, -> { kept.where("polls.closed_at IS NULL or polls.closed_at > ?", 7.days.ago) }
  scope :search_for, ->(fragment) { kept.where("polls.title ilike :fragment", fragment: "%#{fragment}%") }
  scope :lapsed_but_not_closed, -> { active.where("polls.closing_at < ?", Time.now) }
  scope :active_or_closed_after, ->(since) { kept.where("polls.closed_at IS NULL OR polls.closed_at > ?", since) }
  scope :in_organisation, -> (group) { kept.where(group_id: group.id_and_subgroup_ids) }

  scope :with_includes, -> { includes(
    :documents,
    :poll_options,
    :outcomes,
    {stances: [:stance_choices]})
  }

  scope :closing_soon_not_published, ->(timeframe, recency_threshold = 24.hours.ago) do
     active
    .distinct
    .where(closing_at: timeframe)
    .where("NOT EXISTS (SELECT 1 FROM events
                WHERE events.created_at     > ? AND
                      events.eventable_id   = polls.id AND
                      events.eventable_type = 'Poll' AND
                      events.kind           = 'poll_closing_soon')", recency_threshold)
  end

  validates :poll_type, inclusion: { in: AppConfig.poll_templates.keys }
  validates :details, length: {maximum: Rails.application.secrets.max_message_length }

  validate :poll_options_are_valid
  validate :valid_minimum_stance_choices
  validate :closes_in_future
  validate :require_custom_fields
  validate :discussion_group_is_poll_group
  validate :cannot_deanonymize
  validate :cannot_reveal_results_early
  validate :title_if_not_discarded

  alias_method :user, :author

  has_paper_trail only: [
    :author_id,
    :title,
    :details,
    :details_format,
    :closing_at,
    :closed_at,
    :group_id,
    :discussion_id,
    :anonymous,
    :discarded_at,
    :discarded_by,
    :stances_in_discussion,
    :voter_can_add_options,
    :anyone_can_participate,
    :specified_voters_only,
    :notify_on_closing_soon,
    :poll_option_names,
    :hide_results_until_closed]

  update_counter_cache :group, :polls_count
  update_counter_cache :group, :closed_polls_count
  update_counter_cache :discussion, :closed_polls_count
  update_counter_cache :discussion, :anonymous_polls_count

  delegate :locale, to: :author

  def user_id
    author_id
  end

  def existing_member_ids
    voter_ids
  end

  def decided_voters_count
    voters_count - undecided_voters_count
  end

  def cast_stances_pct
    return 0 if voters_count == 0
    ((decided_voters_count.to_f / voters_count) * 100).to_i
  end

  def voters
    anonymous? ? User.none : super
  end

  def undecided_voters
    anonymous? ? User.none : super
  end

  def decided_voters
    anonymous? ? User.none : super
  end

  def unmasked_voters
    User.where(id: stances.latest.pluck(:participant_id))
  end

  def unmasked_undecided_voters
    User.where(id: stances.latest.undecided.pluck(:participant_id))
  end

  def unmasked_decided_voters
    User.where(id: stances.latest.decided.pluck(:participant_id))
  end

  def body
    details
  end

  def body_format
    details_format
  end

  def time_zone
    custom_fields.fetch('time_zone', author.time_zone)
  end

  def show_results?
    closed? || !hide_results_until_closed
  end

  def parent_event
    if discussion
      discussion.created_event
    else
      nil
    end
  end

  # creates a hash which has a PollOption as a key, and a list of stance
  # choices associated with that PollOption as a value
  def grouped_stance_choices(since: nil)
    @grouped_stance_choices ||= stance_choices.reasons_first
                                              .where("stance_choices.created_at > ?", since || 100.years.ago)
                                              .includes(:poll_option, stance: :participant)
                                              .where("stances.latest": true)
                                              .to_a
                                              .group_by(&:poll_option)
  end

  def group
    super || NullGroup.new
  end

  def stance_counts
    show_results? ? super : []
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
    update_columns(
      stance_counts: poll_options.map(&:total_score), # should rename to option scores
      voters_count: stances.latest.count,
      undecided_voters_count: stances.latest.undecided.count,
      versions_count:  versions.count
    )
  end

  # people who can vote.
  def base_membership_query(admin: false)
    if persisted? && specified_voters_only && !admin
      # voters
      User.active.
        joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
        joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{self.id || 0}").
        where("s.id IS NOT NULL AND s.revoked_at IS NULL AND latest = TRUE")
    else
      User.active.
        joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.discussion_id || 0} AND dr.user_id = users.id").
        joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
        joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{self.id || 0}").
        where("(dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL #{'AND dr.admin = TRUE' if admin}) OR
               (m.id  IS NOT NULL AND m.archived_at IS NULL #{'AND m.admin = TRUE' if admin}) OR
               (s.id  IS NOT NULL AND s.revoked_at  IS NULL AND latest = TRUE #{'AND s.admin = TRUE' if admin})")
    end
  end

  def admins
    base_membership_query(admin: true)
  end

  def members
    base_membership_query
  end

  def guests
    base_membership_query.where('m.group_id is null')
  end

  def non_voters
    # people who have not been given a vote yet
    User.active.
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{self.id || 0} AND s.latest = TRUE").
      where('(m.id IS NOT NULL AND m.archived_at IS NULL) AND (s.id IS NULL)')
  end

  def add_guest!(user, author)
    stances.create!(participant_id: user.id, inviter: author, volume: DiscussionReader.volumes[:normal])
  end

  def add_admin!(user, author)
    stances.create!(participant_id: user.id, inviter: author, volume: DiscussionReader.volumes[:normal], admin: true)
  end

  def active?
    (closing_at && closing_at > Time.now) && !closed_at
  end

  def wip?
    closing_at.nil?
  end

  def closed?
    !!closed_at
  end

  def is_single_vote?
    AppConfig.poll_templates.dig(self.poll_type, 'single_choice') && !self.multiple_choice
  end

  def poll_option_names
    poll_options.map(&:name)
  end

  def poll_option_names=(names)
    names    = Array(names)
    existing = Array(poll_options.pluck(:name))
    names = names.sort if poll_type == 'meeting'
    names.each_with_index do |name, priority|
      poll_options.find_or_initialize_by(name: name).priority = priority
    end
    removed = (existing - names)
    poll_options.each {|option| option.mark_for_destruction if removed.include?(option.name) }
    names
  end

  alias options= poll_option_names=
  alias options poll_option_names

  def is_new_version?
    !self.poll_options.map(&:persisted?).all? ||
    (['title', 'details', 'closing_at'] & self.changes.keys).any?
  end

  def discussion_id=(discussion_id)
    super.tap { self.group_id = self.discussion&.group_id }
  end

  def discussion=(discussion)
    super.tap { self.group_id = self.discussion&.group_id }
  end

  def minimum_stance_choices
    self.custom_fields.fetch('minimum_stance_choices', 1).to_i
  end

  def prioritise_poll_options!
    if self.poll_type == 'meeting'
      self.poll_options.sort {|a,b| a.name <=> b.name }.each_with_index {|o, i| o.priority = i }
    end
  end

  private

  def title_if_not_discarded
    if !discarded_at && title.to_s.empty?
      errors.add(:title, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end

  def set_stances_in_discussion
    return unless has_attribute?(:stances_in_discussion) # allow older migrations to pass
    self.stances_in_discussion = false if anonymous or hide_results_until_closed
  end

  def cannot_deanonymize
    if anonymous_changed? && anonymous_was == true
      errors.add :anonymous, :cannot_deanonymize
    end
  end

  def cannot_reveal_results_early
    if hide_results_until_closed_changed? && hide_results_until_closed_was == true
      errors.add :hide_results_until_closed, :cannot_show_results_early
    end
  end

  # provides a base hash of 0's to merge with stance data
  def zeroed_poll_options
    self.poll_options.map { |option| [option.name, 0] }.to_h
  end

  def poll_options_are_valid
    prevent_added_options   unless can_add_options
    prevent_removed_options unless can_remove_options
    prevent_empty_options   if     must_have_options
  end

  def closes_in_future
    return if (closed_at || (closing_at && closing_at > Time.zone.now))
    errors.add(:closing_at, I18n.t(:"validate.motion.must_close_in_future"))
  end

  def discussion_group_is_poll_group
    if poll.group.present? and poll.discussion.present? and poll.discussion.group != poll.group
      self.errors.add(:group, 'Poll group is not discussion group')
    end
  end

  def prevent_added_options
    if (self.poll_options.map(&:name) - template_poll_options).any?
      self.errors.add(:poll_options, I18n.t(:"poll.error.cannot_add_options"))
    end
  end

  def prevent_removed_options
    if (template_poll_options - self.poll_options.map(&:name)).any?
      self.errors.add(:poll_options, I18n.t(:"poll.error.cannot_remove_options"))
    end
  end

  def valid_minimum_stance_choices
    return unless require_stance_choices
    if minimum_stance_choices > poll_options.length
      self.errors.add(:minimum_stance_choices, I18n.t(:"poll.error.minimum_too_high"))
    end
  end

  def prevent_empty_options
    if (self.poll_options.map(&:name)).empty?
      self.errors.add(:poll_options, I18n.t(:"poll.error.must_have_options"))
    end
  end

  def template_poll_options
    Array(poll_options_attributes).map { |o| o['name'] }
  end

  def require_custom_fields
    Array(required_custom_fields).each do |field|
      errors.add(field, I18n.t(:"activerecord.errors.messages.blank")) if custom_fields[field].nil?
    end
  end
end
