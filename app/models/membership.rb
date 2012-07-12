class Membership < ActiveRecord::Base
  ACCESS_LEVELS = ['request', 'member', 'admin']
  MEMBER_ACCESS_LEVELS = ['member', 'admin']

  #
  # VALIDATIONS
  #

  class MemberOfParentGroupValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      if object.group_parent.present? && !object.group_parent.users_include?(value)
        object.errors.add attribute, "must be a member of this group's parent"
      end
    end
  end

  validates :user, member_of_parent_group: true
  validates_presence_of :group, :user
  validates_inclusion_of :access_level, :in => ACCESS_LEVELS
  validates_uniqueness_of :user_id, :scope => :group_id

  #
  # ASSOCIATIONS
  #

  belongs_to :group
  belongs_to :user
  belongs_to :inviter, :class_name => "User"

  has_many :events, :dependent => :destroy

  #
  # ATTRIBUTES / SCOPES / DELEGATES
  #

  attr_accessible :group_id, :access_level

  scope :for_group, lambda {|group| where(:group_id => group)}
  scope :with_access, lambda {|access| where(:access_level => access)}

  delegate :name, :email, :to => :user, :prefix => :user
  delegate :parent, :to => :group, :prefix => :group, :allow_nil => true
  delegate :name, :full_name, :to => :group, :prefix => :group
  delegate :admins, :to => :group, :prefix => :group
  delegate :name, :to => :inviter, :prefix => :inviter, :allow_nil => true

  #
  # CALLBACKS
  #

  after_initialize :set_defaults
  before_destroy :remove_open_votes
  after_destroy :destroy_subgroup_memberships

  #
  # STATE MACHINE
  #

  include AASM
  aasm :column => :access_level do
    state :request, :initial => true
    state :member
    state :admin

    event :approve do
      transitions :to => :member, :from => [:request]
    end

    event :make_admin do
      transitions :to => :admin, :from => [:member]
    end

    event :remove_admin do
      transitions :to => :member, :from => [:admin]
    end
  end

  #
  # PUBLIC METHODS
  #

  def group_has_multiple_admins?
    group.admins.count > 1
  end

  #
  # PRIVATE METHODS
  #

  private

    def destroy_subgroup_memberships
      group.subgroups.each do |subgroup|
        membership = subgroup.memberships.find_by_user_id(user.id)
        membership.destroy if membership
      end
    end

    def remove_open_votes
      user.open_votes.each do |vote|
        vote.destroy
      end
    end

    def set_defaults
      self.access_level ||= 'request'
    end
end
