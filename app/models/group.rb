class Group < ActiveRecord::Base
  validates_presence_of :name
  has_many :memberships,
           :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
           :dependent => :destroy,
           :extend => GroupMemberships
  has_many :membership_requests,
           :conditions => {:access_level => 'request'},
           :class_name => 'Membership'
  has_many :admin_memberships,
           :conditions => {:access_level => 'admin'},
           :class_name => 'Membership'
  has_many :users, :through => :memberships
  has_many :admins, through: :admin_memberships, source: :user
  has_many :motions

  acts_as_tagger

  def add_request!(user)
    unless requested_users_include?(user) || users.exists?(user)
      m = memberships.build_for_user(user, access_level: 'request')
      m.save!
    end
  end

  def add_member!(user)
    unless users.exists?(user)
      unless m = requested_users_include?(user)
        m = memberships.build_for_user(user)
      end
      m.access_level = 'member'
      m.save!
    end
  end

  def add_admin!(user)
    unless (m = memberships.find_by_user_id(user) ||
            m = membership_requests.find_by_user_id(user))
      m = memberships.build_for_user(user)
    end
    m.access_level = 'admin'
    m.save!
  end

  def requested_users_include?(user)
    membership_requests.find_by_user_id(user)
  end

  def can_be_edited_by?(user)
    users.include? user
  end

  def has_admin_user?(user)
    admins.include?(user)
  end
end
