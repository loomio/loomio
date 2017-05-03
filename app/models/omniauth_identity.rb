class OmniauthIdentity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :identity_type

  def self.from_omniauth(identity_type, uid, user_info)
    where(identity_type: identity_type, uid: uid).first_or_create do |record|
      record.email = user_info['email']
      record.name = user_info['name']
    end
  end
end
