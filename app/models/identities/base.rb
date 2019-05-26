class Identities::Base < ApplicationRecord
  extend HasCustomFields
  self.table_name = :omniauth_identities
  validates :identity_type, presence: true
  validates :access_token, presence: true, if: :requires_access_token?
  validates :uid, presence: true

  belongs_to :user, required: false

  PROVIDERS = YAML.load_file(Rails.root.join("config", "providers.yml"))['identity']
  self.inheritance_column = :identity_type
  self.store_full_sti_class = false
  scope :with_user, -> { where.not(user: nil) }
  scope :slack, -> { where(identity_type: :slack) }

  def self.set_identity_type(type)
    after_initialize { self.identity_type = type }
  end

  def create_user!
    User.new(name: self.name, email: self.email).associate_with_identity(self)
  end

  def assign_logo!
    return unless user && logo
    user.uploaded_avatar = open URI.parse(logo)
    user.update(avatar_kind: :uploaded)
  rescue OpenURI::HTTPError, TypeError
    # Can't load logo uri as attachment; do nothing
  end

  def requires_access_token?
    true
  end
end
