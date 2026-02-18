class Identity < ApplicationRecord
  extend HasCustomFields
  self.table_name = :omniauth_identities

  validates :identity_type, presence: true
  validates :uid, presence: true

  belongs_to :user, required: false

  PROVIDERS = YAML.load_file(Rails.root.join("config", "providers.yml"))['identity']

  scope :with_user, -> { where.not(user: nil) }
  scope :pending, -> { where(user: nil) }
  scope :stale, ->(days: 7) { pending.where('created_at < ?', days.days.ago) }

  def assign_logo!
    return unless user && logo
    user.uploaded_avatar.attach(
      io: URI.open(URI.parse(logo)),
      filename: File.basename(logo)
    )
    user.update(avatar_kind: :uploaded)
  rescue OpenURI::HTTPError, TypeError
    # Can't load logo uri as attachment; do nothing
  end
end
