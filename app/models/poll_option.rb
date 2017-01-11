class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  has_many :stances, dependent: :destroy
end
