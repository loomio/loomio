class MembershipRequest < ApplicationRecord
  include HasNotifications

  validate :validate_not_in_group_already
  validate :validate_unique_membership_request
  validates_presence_of :responder, if: :responded?

  validates :group, presence: true

  validates_length_of :introduction, maximum: 250, unless: :persisted?

  belongs_to :group
  belongs_to :requestor, class_name: 'User'
  belongs_to :user, foreign_key: 'requestor_id' # duplicate relationship for eager loading
  belongs_to :responder, class_name: 'User'
  has_many :admins, through: :group

  validates :introduction, length: { maximum: AppConfig.app_features[:max_message_length] }
  validates :decline_reason, length: { maximum: 500 }
  validates :decline_reason, presence: true, on: :decline
  validate :validate_single_response
  validate :validate_response_is_final

  scope :pending, -> { where(approved_at: nil, declined_at: nil).order(created_at: :desc) }
  scope :responded_to, -> { where.not(approved_at: nil).or(where.not(declined_at: nil)).order(Arel.sql('COALESCE(approved_at, declined_at) DESC')) }
  scope :requested_by, ->(user) { where requestor_id: user.id }

  delegate :members,              to: :group, prefix: true
  delegate :membership_requests,  to: :group, prefix: true
  delegate :members_can_add_members, to: :group, prefix: true
  delegate :name,                 to: :group, prefix: true
  delegate :mailer,               to: :group

  delegate :email,                to: :requestor, allow_nil: true
  delegate :name,                 to: :requestor, allow_nil: true

  def author_id
    requestor_id
  end

  def title_model
    group
  end

  def user_id
    requestor_id
  end

  def approve!(responder)
    self.responder = responder
    self.approved_at = Time.current
    self.declined_at = nil
    self.decline_reason = nil
    save!
  end

  def decline!(responder, decline_reason:)
    set_declined_details(responder, decline_reason)
    save!(context: :decline)
  end

  def ignore!(responder)
    set_declined_details(responder, nil)
    save!
  end

  def convert_to_membership!
    group.add_member!(requestor)
  end

  def content_locale
    stripped_text = Rails::Html::WhiteListSanitizer.new.sanitize(introduction, tags: [])
    result = CLD.detect_language stripped_text
    result[:reliable] ? result[:code] : requestor&.locale
  end

  private

  def responded?
    approved_at.present? || declined_at.present?
  end

  def validate_single_response
    errors.add(:base, "Membership request cannot be both approved and declined") if approved_at.present? && declined_at.present?
  end

  def validate_response_is_final
    return unless persisted? && (approved_at_was.present? || declined_at_was.present?)
    return unless approved_at_changed? || declined_at_changed? || decline_reason_changed?

    errors.add(:base, "Membership request has already been responded to")
  end

  def validate_not_in_group_already
    if has_not_been_saved_yet? && already_in_group?
      add_already_in_group_error
    end
  end

  def validate_unique_membership_request
    if has_not_been_saved_yet? && membership_request_blocks_reapplication?
      add_already_requested_membership_error
    end
  end

  def has_not_been_saved_yet?
    not persisted?
  end

  def already_in_group?
    group_members.exists?(requestor.id)
  end

  def membership_request_blocks_reapplication?
    # A reasoned decline invites another application; a pending or silently ignored request does not.
    request = group_membership_requests.where(requestor_id: requestor.id).order(created_at: :desc, id: :desc).first
    return false unless request

    (request.approved_at.blank? && request.declined_at.blank?) ||
      (request.declined_at.present? && request.decline_reason.blank?)
  end

  def add_already_requested_membership_error
    errors.add(:requestor, I18n.t(:'error.you_have_already_requested_membership'))
  end

  def add_already_in_group_error
    errors.add(:requestor, I18n.t(:'error.you_are_already_a_member_of_this_group'))
  end

  def set_declined_details(responder, decline_reason)
    self.responder = responder
    self.approved_at = nil
    self.declined_at = Time.current
    self.decline_reason = decline_reason
  end
end
