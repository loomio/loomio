class Identities::Base < ActiveRecord::Base
  extend HasCustomFields
  self.table_name = :omniauth_identities
  validates :identity_type, presence: true
  validates :access_token, presence: true

  belongs_to :user, required: false
  has_many :communities, class_name: "Communities::Base", foreign_key: :identity_id

  PROVIDERS = YAML.load_file(Rails.root.join("config", "providers.yml"))['identity']
  discriminate Identities, on: :identity_type

  def self.set_identity_type(type)
    after_initialize { self.identity_type = type }
  end

  def fetch_user_info
    apply_user_info(client.fetch_user_info.json)
  end

  private

  # called by default immediately after an access token is obtained.
  # Define a method here to get some basic information about the user,
  # like name, email, profile image, etc
  def apply_user_info(payload)
    raise NotImplementedError.new
  end
end
