class Vote < ActiveRecord::Base
  POSITIONS = %w[yes no abstain block]
  belongs_to :motion
  belongs_to :user

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, :in => POSITIONS
end
