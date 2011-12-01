class Motion < ActiveRecord::Base
  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  has_many :votes
  validates_presence_of :name, :group, :author, :facilitator_id

  def user_has_voted?(user)
    self.votes.map{|v| v.id}.include? user.id
  end
end
