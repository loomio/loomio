class PollTemplate < ActiveRecord::Base
  has_many :poll_options
  has_many :polls

  validates :name, presence: true
end
