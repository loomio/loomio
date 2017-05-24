class Identities::Base < ActiveRecord::Base
  extend HasCustomFields
  self.table_name = :omniauth_identities
  validates :identity_type, presence: true
  validates :access_token, presence: true
  validates :uid, presence: true

  belongs_to :user, required: false
  has_many :communities, class_name: "Communities::Base", foreign_key: :identity_id

  PROVIDERS = YAML.load_file(Rails.root.join("config", "providers.yml"))['identity']
  discriminate Identities, on: :identity_type
  scope :with_user, -> { where.not(user: nil) }

  def self.set_identity_type(type)
    after_initialize { self.identity_type = type }
  end

  def create_user!
    User.new(name: self.name, email: self.email).associate_with_identity(self)
  end

  def assign_logo!
    return unless user && logo
    user.uploaded_avatar = URI.parse(logo)
    user.update(avatar_kind: :uploaded)
  rescue OpenURI::HTTPError
    # Can't load logo uri as attachment; do nothing
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
