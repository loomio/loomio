class Poll < ActiveRecord::Base
  include ReadableUnguessableUrls
  TEMPLATES = YAML.load_file('config/poll_templates.yml')

  belongs_to :author, class_name: "User", required: true
  has_one    :outcome

  belongs_to :motion
  belongs_to :discussion
  delegate   :group, :group_id, to: :discussion, allow_nil: true

  attr_accessor :make_announcement

  has_many :stances
  has_many :voters,       through: :stances, source: :participant, source_type: "User"
  # has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

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

  validates :title, presence: true
  validates :graph_type, presence: true
  validates :poll_type, inclusion: { in: TEMPLATES.keys }
  # validates :communities, length: { minimum: 1 }

  validate :added_poll_options, unless: :can_add_options
  validate :removed_poll_options, unless: :can_remove_options

  # NB this is an Array and NOT an ActiveRecord::Relation.
  # This could possibly be improved.
  # Also, maybe it doesn't matter.
  # def voters
  #   @voters ||= users + visitors
  # end

  def open?
    closed_at.nil?
  end

  def poll_type=(type)
    self[:poll_type] = type
    assign_attributes(TEMPLATES.fetch(type, {}))
  end

  private

  def options_from_template
    Array(TEMPLATES.dig(self.poll_type, 'poll_options_attributes'))
  end

  def added_poll_options
    if (self.poll_options.map(&:name) - options_from_template.map { |o| o['name'] }).length > 0
      self.errors.add(:poll_options, "Cannot add options to this poll")
    end
  end

  def removed_poll_options
    if self.poll_options.length < options_from_template.length
      self.errors.add(:poll_options, "Cannot remove options from this poll")
    end
  end

end
