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
  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :motions

  acts_as_tagger

  def add_request!(user)
    unless requested_users_include?(user) || users.exists?(user)
      membership = memberships.build_for_user(user, access_level: 'request')
      membership.save!
      GroupMailer.new_membership_request(membership).deliver
      reload
      membership
    end
  end

  def add_member!(user)
    unless users.exists?(user)
      unless membership = requested_users_include?(user)
        membership = memberships.build_for_user(user)
      end
      membership.access_level = 'member'
      membership.save!
      reload
      membership
    end
  end

  def add_admin!(user)
    unless (membership = memberships.find_by_user_id(user) ||
            membership = membership_requests.find_by_user_id(user))
      membership = memberships.build_for_user(user)
    end
    membership.access_level = 'admin'
    membership.save!
    reload
    membership
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
