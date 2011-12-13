class Vote < ActiveRecord::Base
  POSITIONS = %w[yes abstain no block]
  belongs_to :motion, :counter_cache => :votes_counter
  belongs_to :user

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_uniqueness_of :user_id, scope: :motion_id
  validates_length_of :statement, maximum: 250
end
