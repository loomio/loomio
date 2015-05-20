class OmniauthIdentity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider

  def self.from_omniauth(provider, uid, user_info)
    where(provider: provider, uid: uid).first_or_create do |record|
      record.email = user_info['email']
      record.name = user_info['name']
    end
  end

  def provider_name
    case provider
    when 'facebook' then 'Facebook'
    when 'google' then 'Google'
    when 'browser_id' then 'Persona'
    when 'twitter' then 'Twitter'
    when 'custom_oauth2' then Rails.application.secrets.custom_oauth2_name
    else
      'Provider'
    end
  end
end
