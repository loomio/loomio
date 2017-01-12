class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices
  has_many :stances, through: :stance_choices, dependent: :destroy
end
