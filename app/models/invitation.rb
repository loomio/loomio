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
  update_counter_cache :invitable, :pending_invitations_count

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
  scope :ignored, -> (send_count, since) { pending.where(send_count: send_count).where('created_at < ?', since) }

  alias :group :invitable

  def invitable_name
    invitable&.full_name
  end

  def cancel!(args = {})
    update!(args.slice(:canceller).merge(cancelled_at: DateTime.now))
  end

  def cancelled?
    invitable.blank? || cancelled_at
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

  def is_pending?
    !cancelled? && !accepted?
  end

  private
  def ensure_token_is_present
    set_unique_token unless self.token
  end

  def set_unique_token
    begin
      token = SecureRandom.hex.slice(0, 20)
    end while self.class.where(token: token).exists?
    self.token = token
  end

end
