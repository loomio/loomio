class Poll < ActiveRecord::Base
  belongs_to :poll_template, required: false
  belongs_to :author, class_name: "User", required: true
  belongs_to :outcome_author, class_name: "User", required: false

  has_many :stances

  has_many :poll_poll_options
  has_many :poll_options, through: :poll_poll_options

  has_many :users,        through: :stances, source: :participant, source_type: "User"
  has_many :visitors,     through: :stances, source: :participant, source_type: "Visitor"

  has_many :poll_communities
  has_many :communities,  through: :poll_communities

  validates :name, presence: true
  validates :poll_template, presence: true
  validates :poll_options, length: { minimum: 1 }
  validates :communities,  length: { minimum: 1 }

  def participants
    @participants ||= users + visitors # NB this is an Array and NOT an ActiveRecord::Relation
  end
end
