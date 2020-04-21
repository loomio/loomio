class Poll < ApplicationRecord
  extend  HasCustomFields
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include HasEvents
  include HasMentions
  include HasDrafts
  include MessageChannel
  include SelfReferencing
  include UsesOrganisationScope
  include HasMailer
  include Reactable
  include HasCreatedEvent
  include HasRichText

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

  belongs_to :author, class_name: "User", required: true
  has_many   :outcomes, dependent: :destroy
  has_one    :current_outcome, -> { where(latest: true) }, class_name: 'Outcome'

  belongs_to :discussion
  belongs_to :group, class_name: "Group"


  after_update :remove_poll_options

  has_many :stances, dependent: :destroy
  has_many :stance_choices, through: :stances
  has_many :voters,       -> { merge(Stance.latest) }, through: :stances, source: :participant
  has_many :admin_voters, -> { merge(Stance.latest.admin) }, through: :stances, source: :participant
  has_many :undecided,    -> { merge(Stance.latest.undecided) }, through: :stances, source: :participant
  has_many :participants, -> { merge(Stance.latest.decided) }, through: :stances, source: :participant

  has_many :poll_unsubscriptions, dependent: :destroy
  has_many :unsubscribers, through: :poll_unsubscriptions, source: :user

  has_many :poll_options, -> { order('priority') }, dependent: :destroy
  accepts_nested_attributes_for :poll_options, allow_destroy: true

  has_many :documents, as: :model, dependent: :destroy

  default_scope { includes(:poll_options) }
  scope :active, -> { where(closed_at: nil) }
  scope :closed, -> { where("closed_at IS NOT NULL") }
  scope :search_for, ->(fragment) { where("polls.title ilike :fragment", fragment: "%#{fragment}%") }
  scope :lapsed_but_not_closed, -> { active.where("polls.closing_at < ?", Time.now) }
  scope :active_or_closed_after, ->(since) { where("closed_at IS NULL OR closed_at > ?", since) }
  scope :participation_by, ->(participant) { joins(:stances).where("stances.participant_id": participant.id) }
  scope :authored_by, ->(user) { where(author: user) }
  scope :with_includes, -> { includes(
    :documents,
    :poll_options,
    :outcomes,
    {stances: [:stance_choices]})
  }

  scope :closing_soon_not_published, ->(timeframe, recency_threshold = 2.days.ago) do
     active
    .distinct
    .where(closing_at: timeframe)
    .where("NOT EXISTS (SELECT 1 FROM events
                WHERE events.created_at     > ? AND
                      events.eventable_id   = polls.id AND
                      events.eventable_type = 'Poll' AND
                      events.kind           = 'poll_closing_soon')", recency_threshold)
  end

  validates :title, presence: true
  validates :poll_type, inclusion: { in: AppConfig.poll_templates.keys }
  validates :details, length: {maximum: Rails.application.secrets.max_message_length }

  validate :poll_options_are_valid
  validate :valid_minimum_stance_choices
  validate :closes_in_future
  validate :require_custom_fields
  validate :discussion_group_is_poll_group

  alias_method :user, :author
  alias_method :draft_parent, :discussion

  has_paper_trail only: [:title, :details, :closing_at, :group_id]

  def self.always_versioned_fields
    [:title, :details]
  end

  update_counter_cache :group, :polls_count
  update_counter_cache :group, :closed_polls_count
  update_counter_cache :discussion, :closed_polls_count
  define_counter_cache(:stances_count) { |poll| poll.stances.latest.count }
  define_counter_cache(:undecided_count) { |poll| poll.stances.latest.undecided.count }
  define_counter_cache(:versions_count) { |poll| poll.versions.count}

  delegate :locale, to: :author

  def participants_count
    stances_count - undecided_count
  end

  def cast_stances_pct
    return 0 if stances_count == 0
    ((participants_count.to_f / stances_count) * 100).to_i
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

  def update_stance_data
    update_attribute(:stance_data, zeroed_poll_options.merge(
      self.class.connection.select_all(%{
        SELECT poll_options.name, sum(stance_choices.score) as total
        FROM stances
        INNER JOIN stance_choices ON stance_choices.stance_id = stances.id
        INNER JOIN poll_options ON poll_options.id = stance_choices.poll_option_id
        WHERE stances.latest = true AND stances.poll_id = #{self.id}
        GROUP BY poll_options.name
      }).map { |row| [row['name'], row['total'].to_i] }.to_h))

    update_attribute(:stance_counts, poll_options.pluck(:name).map { |name| stance_data[name] })
    poll_options.map(&:update_option_score_counts) if poll.has_option_score_counts

    # TODO: convert this to a SQL query (CROSS JOIN?)
    update_attribute(:matrix_counts,
      poll_options.order(:name).limit(5).map do |option|
        stances.latest.order(:created_at).limit(5).map do |stance|
          # the score of the stance choice which has this poll option in this stance
          stance.stance_choices.find_by(poll_option:option)&.score.to_i
        end
      end
    ) if chart_type == 'matrix'
  end

  def admins
    # User.where(id: [group.admins, discussion&.admins, admin_voters].compact.map {|rel| rel.pluck(:id) }.flatten)
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.discussion_id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{self.id || 0} AND s.latest = TRUE").
      where('(m.admin = TRUE AND m.id IS NOT NULL AND m.archived_at IS NULL) OR
             (dr.admin = TRUE AND dr.id IS NOT NULL and dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
             (s.admin = TRUE AND s.id IS NOT NULL and s.revoked_at IS NULL)')
  end

  def members
    # User.where(id: [group.members, discussion&.readers, voters].compact.map {|rel| rel.pluck(:id) }.flatten)
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.discussion_id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{self.id || 0} AND s.latest = TRUE").
      where('(m.id IS NOT NULL AND m.archived_at IS NULL) OR
             (dr.id IS NOT NULL and dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
             (s.id IS NOT NULL and s.revoked_at IS NULL)')
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
    closed_at.nil?
  end

  def closed?
    !active?
  end

  def is_single_vote?
    AppConfig.poll_templates.dig(self.poll_type, 'single_choice') && !self.multiple_choice
  end

  def meeting_score_tallies
    poll_options.map do |option|
      [option.id, {
        maybe:    option.stance_choices.latest.where(score: 1).count,
        yes:      option.stance_choices.latest.where(score: 2).count
      }]
    end
  end

  def poll_option_names
    poll_options.order(:priority).pluck(:name)
  end

  def poll_option_names=(names)
    names    = Array(names)
    existing = Array(poll_options.pluck(:name))
    names = names.sort if poll_type == 'meeting'
    names.each_with_index do |name, priority|
      poll_options.find_or_initialize_by(name: name).priority = priority
    end
    @poll_option_removed_names = (existing - names)
  end

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

  private

  # provides a base hash of 0's to merge with stance data
  def zeroed_poll_options
    self.poll_options.map { |option| [option.name, 0] }.to_h
  end

  def remove_poll_options
    return unless @poll_option_removed_names.present?
    poll_options.where(name: @poll_option_removed_names).destroy_all
    @poll_option_removed_names = nil
    update_stance_data
  end

  def poll_options_are_valid
    prevent_added_options   unless can_add_options
    prevent_removed_options unless can_remove_options
    prevent_empty_options   if     must_have_options
  end

  def closes_in_future
    return if !self.active? || !self.closing_at || self.closing_at > Time.zone.now
    errors.add(:closing_at, I18n.t(:"validate.motion.must_close_in_future"))
  end

  def discussion_group_is_poll_group
    if poll.discussion and poll.group and poll.discussion.group != poll.group
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
    if (self.poll_options.map(&:name) - Array(@poll_option_removed_names)).empty?
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
