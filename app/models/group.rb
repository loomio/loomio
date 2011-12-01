class Group < ActiveRecord::Base
  validates_presence_of :name
  has_many :membership_requests, 
           :conditions => {:access_level => 'request'}, 
           :class_name => 'Membership'
  has_many :memberships, 
           :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS}
  has_many :users, :through => :memberships 
  has_many :motions

  def add_request!(user)
    unless requested_users_include?(user) || users.exists?(user)
      m = Membership.new
      m.user = user
      m.access_level = 'request'
      m.group = self
      self.memberships << m
      m.save!
    end
  end

  def add_member!(user)
    unless users.exists?(user)
      unless m = requested_users_include?(user)
        m = Membership.new
        m.user = user
        m.group = self
        self.memberships << m
      end
      m.access_level = 'member'
      m.save!
    end
  end

  def requested_users_include?(user)
    membership_requests.find_by_user_id(user)
  end
end
