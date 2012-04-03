class Group < ActiveRecord::Base
  PERMISSION_CATEGORIES = [:everyone, :members, :admins]

  validates_presence_of :name
  validates_inclusion_of :viewable_by, in: PERMISSION_CATEGORIES
  after_initialize :set_defaults

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
  has_many :users, :through => :memberships # TODO: rename to members
  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :motions

  delegate :include?, :to => :users, :prefix => :users

  acts_as_tagger


  #
  # ACCESSOR METHODS
  #

  def viewable_by
    value = read_attribute(:viewable_by)
    value.to_sym if value.present?
  end

  def viewable_by=(value)
    write_attribute(:viewable_by, value.to_s)
  end


  #
  # MEMBERSHIP METHODS
  #

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


  #
  # PERMISSION-CHECKS
  #

  def requested_users_include?(user)
    membership_requests.find_by_user_id(user)
  end

  def can_be_edited_by?(user)
    admins.include? user
  end

  def has_admin_user?(user)
    admins.include?(user)
  end

  def can_be_viewed_by?(user)
    return true if viewable_by == :everyone
    return true if (viewable_by == :members && users.include?(user))
  end


  #
  # TAG-RELATED METHODS
  #

  def get_user_tags(user)
    user.owner_tags_on(self, :group_tags)
  end

  def set_user_tags(user, tags)
    tag user, with: tags, on: :group_tags
  end

  def delete_user_tag(user, tag)
    new_tags = user.group_tags_from(self).join(",").gsub(tag, "")
    set_user_tags user, new_tags
  end

  private

    def set_defaults
      self.viewable_by ||= :everyone
    end
end
