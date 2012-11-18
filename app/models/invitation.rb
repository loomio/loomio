class Invitation < ActiveRecord::Base
  attr_accessible :access_level, :group, :group_id, :inviter, :inviter_id, :recipient_email

  belongs_to :inviter, :class_name => "User"
  belongs_to :group

  validates_uniqueness_of :token

  before_create :generate_token

  def to_param
    token
  end

  def accept!(user)
    group = Group.find(group_id)
    group.add_admin!(user)
    self.accepted = true
    save!
  end

  protected

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while Invitation.where(:token => token).exists?
    self.token = token
  end
end
