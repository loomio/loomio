class Poll < ActiveRecord::Base
  include ReadableUnguessableUrls
  include HasMentions
  TEMPLATES = YAML.load_file('config/poll_templates.yml')

  is_mentionable on: :details

  belongs_to :author, class_name: "User", required: true
  has_one    :outcome

  belongs_to :motion
  belongs_to :discussion
  delegate   :group, :group_id, to: :discussion, allow_nil: true

  attr_accessor :make_announcement

  has_many :stances
  has_many :participants, through: :stances, source: :participant, source_type: "User"
  # has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

  has_many :events, -> { includes(:eventable) }, as: :eventable, dependent: :destroy

  has_many :poll_options
  accepts_nested_attributes_for :poll_options

  has_many :poll_did_not_votes

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

  validates :title, presence: true
  validates :poll_type, inclusion: { in: TEMPLATES.keys }
  # validates :communities, length: { minimum: 1 }

  validate :poll_options_are_valid

  # NB this is an Array and NOT an ActiveRecord::Relation.
  # This could possibly be improved.
  # Also, maybe it doesn't matter.
  # def voters
  #   @voters ||= users + visitors
  # end

  def watchers
    if discussion.present?
      Queries::UsersByVolumeQuery.normal_or_loud(discussion).distinct
    else
      # TODO: look at communities when communities exist
    end
  end

  def update_stance_data
    update(
      stance_data: self.class.connection.select_all(%{
        SELECT poll_options.name, sum(stances.score) as total
        FROM stances
        INNER JOIN poll_options ON poll_options.id = stances.poll_option_id
        WHERE stances.latest = true AND stances.poll_id = #{self.id}
        GROUP BY poll_options.name
      }).map { |row| [row['name'], row['total'].to_i] }.to_h
    )
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

  def graph_type
    template['graph_type']
  end

  def open?
    closed_at.nil?
  end

  private

  def template
    TEMPLATES.fetch(self.poll_type, {})
  end

  def poll_options_are_valid
    prevent_added_options   unless can_add_options
    prevent_removed_options unless can_remove_options
  end

  def prevent_added_options
    if (self.poll_options.map(&:name) - template_poll_options).any?
      self.errors.add(:poll_options, "Cannot add options to this poll")
    end
  end

  def prevent_removed_options
    if (template_poll_options - self.poll_options.map(&:name)).any?
      self.errors.add(:poll_options, "Cannot remove options from this poll")
    end
  end

  def template_poll_options
    Array(template['poll_options_attributes']).map { |o| o['name'] }
  end

end
