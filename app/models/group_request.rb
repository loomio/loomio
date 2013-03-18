class GroupRequest < ActiveRecord::Base

  attr_accessible :admin_name, :admin_email, :country_name, :name, :sectors, :other_sector,
                  :description, :expected_size, :max_size, :cannot_contribute, :robot_trap

  attr_accessor :robot_trap

  validates :admin_name, presence: true, length: {maximum: 250}
  validates :admin_email, presence: true, email: true
  validates :country_name, presence: true
  validates :name, presence: true, length: {maximum: 250}
  validates :sectors, presence: true
  validates :description, presence: true
  validates :expected_size, presence: true

  serialize :sectors, Array

  belongs_to :group

  scope :approved, where(:status => :approved)
  scope :awaiting_approval, where(:status => :awaiting_approval)

  before_create :mark_spam

  include AASM
  aasm :column => :status do  # defaults to aasm_state
    state :awaiting_approval, :initial => true
    state :approved
    state :ignored
    state :marked_as_spam

    event :approve, :before => :approve_request do
      transitions :to => :approved, :from => [:awaiting_approval, :ignored, :marked_as_spam]
    end

    event :ignore do
      transitions :to => :ignored, :from => [:awaiting_approval, :marked_as_spam]
    end

    event :mark_as_already_approved do
      transitions :to => :approved, :from => [:awaiting_approval, :ignored]
    end

    event :mark_as_spam do
      transitions :to => :marked_as_spam, :from => [:awaiting_approval]
    end
  end

  private

  def approve_request
    @group = Group.new :name => name
    @group.creator = User.loomio_helper_bot
    @group.country_name = country_name
    @group.sectors = sectors
    @group.other_sector = other_sector
    @group.max_size = max_size
    @group.cannot_contribute = cannot_contribute
    @group.save!
    @group.create_welcome_loomio
    self.group_id = @group.id
    save!
    InvitesUsersToGroup.invite!(:recipient_emails => [admin_email],
                                :inviter => @group.creator,
                                :group => @group,
                                :access_level => "admin")
  end

  def mark_spam
    mark_as_spam unless robot_trap.blank?
  end
end
