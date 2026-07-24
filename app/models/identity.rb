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

    # `logo` comes from the external SSO/OAuth provider's userinfo response, so
    # it is attacker-influenceable — fetch it through the SSRF-guarded opener
    # rather than a raw URI.open that would follow it to internal/metadata IPs.
    io = LinkPreviewService.safe_open(logo)
    return unless io

    user.uploaded_avatar.attach(io: io, filename: File.basename(logo))
    user.update(avatar_kind: :uploaded)
  rescue StandardError => e
    Rails.logger.warn("assign_logo! failed for identity #{id}: #{e.message}")
  end
end
