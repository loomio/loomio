class StanceChoice < ActiveRecord::Base
  belongs_to :poll_option
  belongs_to :stance, dependent: :destroy
  has_one :poll, through: :poll_option
  delegate :has_variable_score, to: :poll

  validates_presence_of :poll_option
  validates :score, numericality: { greater_than_or_equal_to: 0 }
  validates :score, numericality: { equal_to: 1 }, unless: :has_variable_score

  scope :reasons_first, -> {
    joins(:stance).order("CASE coalesce(stances.reason, '') WHEN '' THEN 1 ELSE 0 END")
                  .order(:created_at)
  }
end
