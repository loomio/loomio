class GroupRequest < ActiveRecord::Base

  attr_accessible :admin_name, :admin_email, :country_name, :name, :sectors, :other_sector,
                  :description, :expected_size, :max_size, :cannot_contribute, :robot_trap

  attr_accessor :robot_trap

  validates :token, :uniqueness => true, :presence => true,
            :length => {:minimum => 20}
  validates :admin_name, presence: true, length: {maximum: 250}
  validates :admin_email, presence: true, email: true
  validates :country_name, presence: true
  validates :name, presence: true, length: {maximum: 250}
  validates :sectors, presence: true
  validates :description, presence: true
  validates :expected_size, presence: true

  serialize :sectors, Array

  belongs_to :group

  scope :verified, where(:status => :verified)
  scope :unverified, where(:status => :unverified)
  scope :approved, where(:status => :approved)
  scope :accepted, where(:status => :accepted)

  before_create :mark_spam
  before_validation :generate_token, on: :create
  after_create :send_verification

  include AASM
  aasm column: :status do  # defaults to aasm_state
    state :unverified, initial: true
    state :verified
    state :approved
    state :accepted
    state :defered
    state :manually_approved
    state :marked_as_spam

    event :verify do
      transitions to: :verified, from: [:unverified]
    end

    event :approve, before: :approve_request do
      transitions to: :approved, from: [:verified, :defered]
    end

    event :accept_request do
      transitions to: :accepted, from: [:approved]
    end

    event :defer do
      transitions to: :defered, from: [:verified]
    end

    event :mark_as_manually_approved do
      transitions to: :manually_approved, from: [:unverified, :verified, :defered]
    end

    event :mark_as_spam do
      transitions to: :marked_as_spam, from: [:unverified, :verified, :defered]
    end

    event :mark_as_unverified do
      transitions to: :unverified, from: [:marked_as_spam, :manually_approved]
    end

  end

  def accept!(user)
    group.add_admin!(user)
    accept_request!
  end


  private

  def send_verification
    StartGroupMailer.verification(self).deliver
  end

  def approve_request
    @group = Group.new name: name
    @group.creator = User.loomio_helper_bot
    @group.country_name = country_name
    @group.sectors = sectors
    @group.other_sector = other_sector
    @group.max_size = max_size
    @group.cannot_contribute = cannot_contribute
    @group.save!
    @group.create_welcome_loomio
    self.group = @group
    save!
    StartGroupMailer.invite_admin_to_start_group(self).deliver
  end

  def mark_spam
    mark_as_spam unless robot_trap.blank?
  end

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while GroupRequest.where(:token => token).exists?
    self.token = token
  end
end
