class Invitation < ActiveRecord::Base
  attr_accessible :access_level, :group_id, :inviter_id, :recipient_email

  belongs_to :inviter, :class_name => "User"
  belongs_to :group

  validates_uniqueness_of :token

  before_create :generate_token

  def to_param
    token
  end

  protected

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while Invitation.where(:token => token).exists?
    self.token = token
  end
end
