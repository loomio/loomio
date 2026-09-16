class MembershipRequest < ApplicationRecord
  include HasNotifications

  validate :validate_not_in_group_already
  validate :validate_unique_membership_request
  validates_presence_of :responder, if: :response

  validates :group, presence: true

  validates_length_of :introduction, maximum: 250, unless: :persisted?

  belongs_to :group
  belongs_to :requestor, class_name: 'User'
  belongs_to :user, foreign_key: 'requestor_id' # duplicate relationship for eager loading
  belongs_to :responder, class_name: 'User'
  has_many :admins, through: :group

  validates :introduction, length: { maximum: AppConfig.app_features[:max_message_length] }
  validates :response_comment, length: { maximum: 500 }
  validates :response_comment, presence: true, if: -> { response == "declined" }

  scope :pending, -> { where(response: nil).order('created_at DESC') }
  scope :responded_to, -> { where('response IS NOT NULL').order('responded_at DESC') }
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

  def approve!(responder, response_comment: nil)
    set_response_details('approved', responder, response_comment)
  end

  def decline!(responder, response_comment:)
    set_response_details('declined', responder, response_comment)
  end

  def ignore!(responder)
    set_response_details('ignored', responder, nil)
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

  def validate_not_in_group_already
    if has_not_been_saved_yet? && already_in_group?
      add_already_in_group_error
    end
  end

  def validate_unique_membership_request
    if has_not_been_saved_yet? && pending_request_already_exists?
      add_already_requested_membership_error
    end
  end

  def has_not_been_saved_yet?
    not persisted?
  end

  def already_in_group?
    group_members.exists?(requestor.id)
  end

  def pending_request_already_exists?
    group_membership_requests.where(requestor_id: requestor.id, response: nil).exists?
  end

  def add_already_requested_membership_error
    errors.add(:requestor, I18n.t(:'error.you_have_already_requested_membership'))
  end

  def add_already_in_group_error
    errors.add(:requestor, I18n.t(:'error.you_are_already_a_member_of_this_group'))
  end

  def set_response_details(response, responder, response_comment)
    self.response = response
    self.responder = responder
    self.response_comment = response_comment
    self.responded_at = Time.now
    save!
  end
end
