class Invitation < ActiveRecord::Base

  class InvitationCancelled < StandardError
  end

  class InvitationAlreadyUsed < StandardError
  end

  extend FriendlyId
  friendly_id :token
  attr_accessible :recipient_email, :inviter, :group, :to_be_admin, :intent
  belongs_to :inviter, class_name: User
  belongs_to :accepted_by, class_name: User
  belongs_to :group
  belongs_to :canceller, class_name: User

  validates_presence_of :group, :intent
  validates_inclusion_of :intent, :in => ['start_group', 'join_group']
  before_save :ensure_token_is_present

  scope :not_cancelled,  -> { where(cancelled_at: nil) }
  scope :pending, -> { not_cancelled.where(accepted_at: nil) }

  def inviter_name
    inviter.name
  end

  def group_name
    group.name
  end

  def group_request_admin_name
    group.group_request.admin_name
  end

  def cancel!(args)
    self.canceller = args[:canceller]
    self.cancelled_at = DateTime.now
    self.save!
  end

  def cancelled?
    cancelled_at.present?
  end

  def accepted?
    accepted_by.present?
  end

  private
  def ensure_token_is_present
    unless self.token.present?
      set_unique_token
    end
  end

  def set_unique_token
    begin
      token = (('a'..'z').to_a +
               ('A'..'Z').to_a + 
               (0..9).to_a).sample(20).join
    end while self.class.where(:token => token).exists?
    self.token = token
  end

end
