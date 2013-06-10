class GroupRequest < ActiveRecord::Base

  attr_accessible :name, :description, :expected_size, :admin_name, :admin_email,
                  :cannot_contribute, :max_size, :high_touch, :robot_trap

  attr_accessor :robot_trap

  validates :name, presence: true, length: {maximum: 250}
  validates :description, presence: true
  validates :expected_size, presence: true
  validates :admin_name, presence: true, length: {maximum: 250}
  validates :admin_email, presence: true, email: true
  validates_inclusion_of :cannot_contribute, :in => [true, false], message: I18n.t("error.group_request_contribution")

  belongs_to :group
  belongs_to :approved_by, class_name: 'User'

  scope :verified, where(:status => :verified)
  scope :starred, where(:high_touch => true)
  scope :not_starred, where(:high_touch => false)
  scope :waiting, -> { verified.not_starred }
  scope :unverified, where(:status => :unverified)
  scope :approved, where(:status => :approved)
  scope :accepted, where(:status => :accepted)

  before_destroy :prevent_destroy_if_group_present
  before_create :mark_spam
  before_validation :generate_token, on: :create

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
      transitions to: :verified, from: [:unverified, :defered]
    end

    event :approve_request do
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

  def approve!(args)
    self.approved_by = args[:approved_by]
    update_attribute(:approved_at, DateTime.now)
    approve_request
    save!
  end

  def accept!(user)
    group.add_admin!(user)
    accept_request
    save!
  end

  def self.check_defered
    defered_requests = GroupRequest.where(status: 'defered')
    defered_requests.each do |group_request|
      group_request.verify! if group_request.defered_until < Time.now
    end
  end


  private
  def prevent_destroy_if_group_present
    if self.group.present?
      errors.add(:group, "dont' delete group requests ok!")
    end
    errors.blank?
  end

  def mark_spam
    mark_as_spam unless robot_trap.blank?
  end

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while self.class.where(:token => token).exists?
    self.token = token
  end
end
