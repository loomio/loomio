class Membership < ActiveRecord::Base
  attr_accessible :group_id, :access_level
  after_initialize :set_defaults

  ACCESS_LEVELS = ['request', 'member', 'admin']
  MEMBER_ACCESS_LEVELS = ['member', 'admin']
  belongs_to :group
  belongs_to :user
  validates_presence_of :group, :user
  validates_inclusion_of :access_level, :in => ACCESS_LEVELS
  validates_uniqueness_of :user_id, :scope => :group_id

  scope :for_group, lambda {|group| where(:group_id => group)}
  scope :with_access, lambda {|access| where(:access_level => access)}

  delegate :name, :email, :to => :user, :prefix => :user

  private

    def set_defaults
      self.access_level ||= 'request'
    end
end
