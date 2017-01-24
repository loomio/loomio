class Poll < ActiveRecord::Base
  include ReadableUnguessableUrls
  include HasMentions
  TEMPLATES = YAML.load_file('config/poll_templates.yml')
  COLORS    = YAML.load_file('config/colors.yml')

  is_mentionable on: :details

  belongs_to :author, class_name: "User", required: true
  has_one    :outcome

  belongs_to :motion
  belongs_to :discussion
  delegate   :group, :group_id, to: :discussion, allow_nil: true

  update_counter_cache :discussion, :closed_polls_count

  attr_accessor :make_announcement

  after_update :remove_poll_options

  has_many :stances
  has_many :stance_choices, through: :stances
  has_many :participants, through: :stances, source: :participant, source_type: "User"
  # has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

  has_many :events, -> { includes(:eventable) }, as: :eventable, dependent: :destroy

  has_many :poll_options, dependent: :destroy
  accepts_nested_attributes_for :poll_options, allow_destroy: true

  has_many :poll_did_not_votes

  define_counter_cache(:stances_count) { |poll| poll.stances.latest.count }
  # has_many :poll_communities
  # has_many :communities, through: :poll_communities

  # has_many :poll_references

  # there's some duplication here, but it's pretty unlikely we'll need references
  # to other models, so it's unlikely to blow out
  # def group
  #   @group      ||= poll_references.find_by(reference_type: 'Group')&.reference
  # end
  #
  # def discussion
  #   @discussion ||= poll_references.find_by(reference_type: 'Discussion')&.reference
  # end
  #
  # def motion
  #   @motion     ||= poll_references.find_by(reference_type: 'Motion')&.reference
  # end

  scope :active, -> { where(closed_at: nil) }
  scope :closed, -> { where("closed_at IS NOT NULL") }
  scope :search_for, ->(fragment) { where("polls.title ilike :fragment", fragment: "%#{fragment}%") }

  validates :title, presence: true
  validates :poll_type, inclusion: { in: TEMPLATES.keys }
  # validates :communities, length: { minimum: 1 }

  validate :poll_options_are_valid

  def watchers
    if discussion.present?
      Queries::UsersByVolumeQuery.normal_or_loud(discussion)
    else
      # TODO: look at communities when communities exist
    end
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
  end

  def material_icon
    template['material_icon']
  end

  def can_add_options
    template['can_add_options']
  end

  def can_remove_options
    template['can_remove_options']
  end

  def must_have_options
    template['must_have_options']
  end

  def chart_type
    template['chart_type']
  end

  def active?
    closed_at.nil?
  end

  def poll_option_names
    poll_options.pluck(:name)
  end

  def poll_option_names=(names)
    names    = Array(names)
    existing = Array(poll_options.pluck(:name))
    (names - existing).each { |name| poll_options.build(name: name) }
    @poll_option_removed_names = (existing - names)
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

  def template
    TEMPLATES.fetch(self.poll_type, {})
  end

  def poll_options_are_valid
    prevent_added_options   unless can_add_options
    prevent_removed_options unless can_remove_options
    prevent_empty_options   if     must_have_options
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
    Array(template['poll_options_attributes']).map { |o| o['name'] }
  end

end
