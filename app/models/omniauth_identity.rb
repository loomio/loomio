class OmniauthIdentity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |record|
      record.email = auth.info.email
      record.name = auth.info.name
    end
  end

  def provider_name
    case provider
    when 'facebook' then 'Facebook'
    when 'google' then 'Google'
    when 'browser_id' then 'Persona'
    else
      'Provider'
    end
  end
end
