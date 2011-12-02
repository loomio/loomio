class Motion < ActiveRecord::Base
  MOTION_TYPES = %w[proposal discussion]
  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  has_many :votes
  validates_presence_of :name, :group, :author, :facilitator_id,
                        :motion_type
  validates_inclusion_of :motion_type, in: MOTION_TYPES

  def user_has_voted?(user)
    self.votes.map{|v| v.user.id}.include? user.id
  end
end
