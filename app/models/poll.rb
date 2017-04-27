class Poll < ActiveRecord::Base
  include ReadableUnguessableUrls
  include HasMentions
  include MakesAnnouncements
  TEMPLATES = YAML.load_file(Rails.root.join("config", "poll_templates.yml"))
  COLORS    = YAML.load_file(Rails.root.join("config", "colors.yml"))
  TIMEZONES = YAML.load_file(Rails.root.join("config", "timezones.yml"))
  TEMPLATE_FIELDS = %w(material_icon translate_option_name
                       can_add_options can_remove_options
                       must_have_options chart_type has_option_icons
                       has_variable_score voters_review_responses
                       dates_as_options required_custom_fields
                       require_stance_choice poll_options_attributes).freeze
  TEMPLATE_FIELDS.each do |field|
    define_method field, -> { TEMPLATES.dig(self.poll_type, field) }
  end

  is_mentionable on: :details

  belongs_to :author, class_name: "User", required: true
  has_many   :outcomes, dependent: :destroy
  has_one    :current_outcome, -> { where(latest: true) }, class_name: 'Outcome'

  belongs_to :motion
  belongs_to :discussion
  belongs_to :group

  update_counter_cache :discussion, :closed_polls_count

  after_update :remove_poll_options

  has_many :stances, dependent: :destroy
  has_many :stance_choices, through: :stances
  has_many :participants, through: :stances, source: :participant, source_type: "User"
  has_many :visitors, through: :communities
  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :events, -> { includes(:eventable) }, as: :eventable, dependent: :destroy

  has_many :poll_options, ->(object) { order(object.poll_option_order) }, dependent: :destroy
  accepts_nested_attributes_for :poll_options, allow_destroy: true

  has_many :poll_did_not_votes, dependent: :destroy

  has_paper_trail only: [:title, :details, :closing_at]

  define_counter_cache(:stances_count)       { |poll| poll.stances.latest.count }
  define_counter_cache(:did_not_votes_count) { |poll| poll.poll_did_not_votes.count }

  has_many :poll_communities, dependent: :destroy
  has_many :communities, through: :poll_communities

  scope :active, -> { where(closed_at: nil) }
  scope :closed, -> { where("closed_at IS NOT NULL") }
  scope :search_for, ->(fragment) { where("polls.title ilike :fragment", fragment: "%#{fragment}%") }
  scope :lapsed_but_not_closed, -> { active.where("polls.closing_at < ?", Time.now) }
  scope :active_or_closed_after, ->(since) { where("closed_at IS NULL OR closed_at > ?", since) }
  scope :participation_by, ->(participant) { joins(:stances).where("stances.participant_type": participant.class.to_s, "stances.participant_id": participant.id) }
  scope :authored_by, ->(user) { where(author: user) }

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
  validates :poll_type, inclusion: { in: TEMPLATES.keys }

  validate :poll_options_are_valid
  validate :closes_in_future
  validate :require_custom_fields

  alias_method :user, :author

  def poll
    self
  end

  # creates a hash which has a PollOption as a key, and a list of stance
  # choices associated with that PollOption as a value
  def grouped_stance_choices(since: nil)
    @grouped_stance_choices ||= stance_choices.reasons_first
                                              .where("stance_choices.created_at > ?", since || 100.years.ago)
                                              .includes(:poll_option, stance: :participant)
                                              .to_a
                                              .group_by(&:poll_option)
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

    update_attribute(:stance_counts,
      poll_options.order(:priority)
                  .pluck(:name)
                  .map { |name| stance_data[name] })

    # TODO: convert this to a SQL query (CROSS JOIN?)
    update_attribute(:matrix_counts,
      poll_options.limit(5).map do |option|
        stances.latest.limit(5).map do |stance|
          stance.poll_options.include?(option)
        end
      end
    ) if chart_type == 'matrix'
  end

  def active?
    closed_at.nil?
  end

  def poll_option_order
    if dates_as_options then { name: :asc } else :id end
  end

  def poll_option_names
    poll_options.pluck(:name)
  end

  def poll_option_names=(names)
    names    = Array(names)
    existing = Array(poll_options.pluck(:name))
    (names - existing).each_with_index { |name, priority| poll_options.build(name: name, priority: priority) }
    @poll_option_removed_names = (existing - names)
  end

  def anyone_can_participate
    @anyone_can_participate ||= community_of_type(:public).present?
  end

  def anyone_can_participate=(boolean)
    if boolean
      community_of_type(:public, build: true)
    else
      community_of_type(:public)&.destroy
    end
  end

  def discussion=(discussion)
    super.tap { self.group_id = self.discussion&.group_id }
  end

  def discussion_id=(discussion_id)
    super.tap { self.group_id = self.discussion&.group_id }
  end

  def group_id=(group_id)
    return if self[:group_id] == group_id
    super
    poll_communities.where(community: community_of_type(:loomio_group)).destroy_all
    if g = Group.find_by(id: group_id)
      poll_communities.build(community: g.community)
    end
  end

  def community_of_type(community_type, build: false)
    communities.find_by(community_type: community_type) || (build && build_community(community_type)).presence
  end

  private

  def build_community(community_type)
    poll_communities.build(community: "Communities::#{community_type.to_s.camelize}".constantize.new).community
  end

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

  def prevent_empty_options
    if self.poll_options.empty?
      self.errors.add(:poll_options, I18n.t(:"poll.error.must_have_options"))
    end
  end

  def template_poll_options
    Array(poll_options_attributes).map { |o| o['name'] }
  end

  def require_custom_fields
    Array(required_custom_fields).each do |field|
      errors.add(field, I18n.t(:"activerecord.errors.messages.blank")) if custom_fields[field].blank?
    end
  end
end
