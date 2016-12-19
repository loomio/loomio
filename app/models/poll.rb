class Poll < ActiveRecord::Base
  belongs_to :poll_template, required: true
  belongs_to :author, class_name: "User", required: true
  belongs_to :outcome_author, class_name: "User", required: false

  attr_accessor :make_announcement

  has_many :stances
  has_many :users,        through: :stances, source: :participant, source_type: "User"
  has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

  has_many :poll_poll_options
  has_many :poll_options, through: :poll_poll_options

  has_many :poll_communities
  has_many :communities, through: :poll_communities

  has_many :poll_references

  # there's some duplication here, but it's pretty unlikely we'll need references
  # to other models, so it's unlikely to blow out
  def group
    @group      ||= poll_references.find_by(reference_type: 'Group')&.reference
  end

  def discussion
    @discussion ||= poll_references.find_by(reference_type: 'Discussion')&.reference
  end

  def motion
    @motion     ||= poll_references.find_by(reference_type: 'Motion')&.reference
  end

  validates :name, presence: true
  validates :communities, length: { minimum: 1 }

  # NB this is an Array and NOT an ActiveRecord::Relation.
  # This could possibly be improved.
  # Also, maybe it doesn't matter.
  def voters
    @voters ||= users + visitors
  end
end
