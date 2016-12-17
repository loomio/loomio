class Poll < ActiveRecord::Base
  belongs_to :poll_template, required: true
  belongs_to :author, class_name: "User", required: true
  belongs_to :outcome_author, class_name: "User", required: false

  belongs_to :discussion, required: false
  belongs_to :group, required: false

  has_many :stances
  has_many :users,        through: :stances, source: :participant, source_type: "User"
  has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

  has_many :poll_poll_options
  has_many :poll_options, through: :poll_poll_options

  has_many :poll_communities
  has_many :communities,  through: :poll_communities

  validates :name, presence: true
  validates :communities,  length: { minimum: 1 }

  # NB this is an Array and NOT an ActiveRecord::Relation. This could likely be improved.
  def participants
    @participants ||= users + visitors
  end
end
