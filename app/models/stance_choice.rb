class StanceChoice < ActiveRecord::Base
  belongs_to :poll_option
  belongs_to :stance, dependent: :destroy

  validates_presence_of :poll_option
end
