class Group < ActiveRecord::Base
  MEMBER_ACCESS_LEVELS = ['member', 'admin']
  validates_presence_of :name
  has_many :membership_requests, :conditions => {:access_level => 'request'}, :class_name => 'Membership'
  has_many :memberships, :conditions => {:access_level => MEMBER_ACCESS_LEVELS}
  has_many :users, :through => :memberships 
  has_many :motions

  def add_request!(user)
    m = Membership.new
    m.user = user
    self.memberships << m
    m.save!
  end

  def add_member!(user)
    m = Membership.new
    m.user = user
    m.access_level = 'member'
    self.memberships << m
    m.save!
  end
end
