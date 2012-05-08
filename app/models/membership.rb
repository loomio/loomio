class Membership < ActiveRecord::Base
  after_initialize :set_defaults
  before_destroy :remove_open_votes

  ACCESS_LEVELS = ['request', 'member', 'admin']
  MEMBER_ACCESS_LEVELS = ['member', 'admin']
  belongs_to :group
  belongs_to :user
  validates_presence_of :group, :user
  validates_inclusion_of :access_level, :in => ACCESS_LEVELS
  validates_uniqueness_of :user_id, :scope => :group_id

  attr_accessible :group_id, :access_level
  
  scope :for_group, lambda {|group| where(:group_id => group)}
  scope :with_access, lambda {|access| where(:access_level => access)}

  delegate :name, :email, :to => :user, :prefix => :user

  def can_be_made_admin_by?(user)
    group.admins.include? user
  end

  def can_be_made_member_by?(user)
    group.users.include? user
  end

  def can_be_deleted_by?(user)
    # Admins can delete everyone except admins
    return false if group.admins.include?(self.user)
    return true if group.admins.include?(user)

    return true if self.user == user
    return true if (access_level == 'request' && group.users.include?(user))
  end

  private
    def remove_open_votes
      user.votes.each do |vote|
        motion = Motion.find(vote.motion_id)
        if motion.voting?
          vote.destroy
        end
      end
    end
    def set_defaults
      self.access_level ||= 'request'
    end
end
