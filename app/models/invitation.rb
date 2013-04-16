class Invitation < ActiveRecord::Base
  extend FriendlyId
  friendly_id :token
  attr_accessible :recipient_email, :inviter, :group, :to_be_admin
  belongs_to :inviter, class_name: User
  belongs_to :accepted_by, class_name: User
  belongs_to :group

  validates_presence_of :group
  before_save :ensure_token_is_present

  def inviter_name
    inviter.name
  end

  def group_name
    group.name
  end

  private
  def ensure_token_is_present
    unless self.token.present?
      set_unique_token
    end
  end

  def set_unique_token
    begin
      token = SecureRandom.urlsafe_base64
    end while self.class.where(:token => token).exists?
    self.token = token
  end
end
