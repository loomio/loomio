class Invitation < ActiveRecord::Base

  class InvitationCancelled < StandardError
  end

  class InvitationAlreadyUsed < StandardError
  end

  extend FriendlyId
  friendly_id :token
  belongs_to :inviter, class_name: User
  belongs_to :invitable, polymorphic: true
  belongs_to :canceller, class_name: User

  update_counter_cache :invitable, :invitations_count

  validates_presence_of :invitable, :intent
  validates_inclusion_of :invitable_type, :in => ['Group', 'Discussion']
  validates_inclusion_of :intent, :in => ['start_group', 'join_group', 'join_discussion']
  scope :chronologically, -> { order('id asc') }
  before_save :ensure_token_is_present

  delegate :name, to: :inviter, prefix: true, allow_nil: true

  scope :not_cancelled,  -> { where(cancelled_at: nil) }
  scope :pending, -> { not_cancelled.single_use.where(accepted_at: nil) }
  scope :shareable, -> { not_cancelled.where(single_use: false) }
  scope :single_use, -> { not_cancelled.where(single_use: true) }


  def recipient_first_name
    recipient_name.split(' ').first
  end

  def group
    case invitable_type
    when 'Group'
      invitable
    when 'Discussion'
      invitable.group
    end
  end

  def invitable_name
    case invitable_type
    when 'Group'
      invitable.full_name
    when 'Discussion'
      invitable.title
    end
  end

  def group_request_admin_name
    if invitable_type == 'Group'
      invitable.group_request.admin_name
    end
  end

  def cancel!(args)
    self.canceller = args[:canceller]
    self.cancelled_at = DateTime.now
    self.save!
  end

  def cancelled?
    if invitable.blank?
      true
    else
      cancelled_at.present?
    end
  end

  def accepted?
    accepted_at.present?
  end

  def to_start_group?
    intent == 'start_group'
  end

  def to_join_group?
    intent == 'join_group'
  end

  private
  def ensure_token_is_present
    unless self.token.present?
      set_unique_token
    end
  end

  def set_unique_token
    begin
      token = SecureRandom.hex.slice(0, 20)
    end while self.class.where(:token => token).exists?
    self.token = token
  end

end
