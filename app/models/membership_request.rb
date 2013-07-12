class MembershipRequest < ActiveRecord::Base

  attr_accessible :name, :email, :introduction

  validates :name,  presence: true, :if => 'requestor.blank?'
  validates :email, presence: true, email: true, :if => 'requestor.blank?' #this uses the gem 'valid_email'

  validate :validate_not_in_group_already
  validate :validate_unique_membership_request
  validates_presence_of :responder, :if => 'response.present?'

  validates :group, presence: true

  belongs_to :group
  belongs_to :requestor, class_name: 'User'
  belongs_to :responder, class_name: 'User'

  delegate :admins,               to: :group, prefix: true
  delegate :members,              to: :group, prefix: true
  delegate :membership_requests,  to: :group, prefix: true
  delegate :members_invitable_by, to: :group, prefix: true
  delegate :name,                 to: :group, prefix: true

  def name
    if requestor.present?
      requestor.name
    else
      self[:name]
    end
  end

  def email
    if requestor.present?
      requestor.email
    else
      self[:email]
    end
  end

  def approve!(responder)
    set_response_details('approved', responder)
  end

  def ignore!(responder)
    set_response_details('ignored', responder)
  end

  def from_a_visitor?
    requestor.blank?
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
    if from_a_visitor?
      group_members.find_by_email(email)
    else
      group_members.include?(requestor)
    end
  end

  def pending_request_already_exists?
    if from_a_visitor?
      group_membership_requests.where(response: nil, email: email).exists?
    else
      group_membership_requests.where(requestor_id: requestor.id, response: nil).exists?
    end
  end

  def add_already_requested_membership_error
    if from_a_visitor?
      errors.add(:email, I18n.t(:'error.you_have_already_requested_membership'))
    else
      errors.add(:requestor, I18n.t(:'error.you_have_already_requested_membership'))
    end
  end

  def add_already_in_group_error
    if from_a_visitor?
      errors.add(:email, I18n.t(:'error.user_with_email_address_already_in_group'))
    else
      errors.add(:requestor, I18n.t(:'error.you_are_already_a_member_of_this_group'))
    end
  end

  def set_response_details(response, responder)
    self.response = response
    self.responder = responder
    self.responded_at = Time.now
    save!
  end
end
