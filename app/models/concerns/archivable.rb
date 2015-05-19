module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where('archived_at is not null') }
    scope :published, -> { where(archived_at: nil) }
  end

  def archive
    update_attributes(archived_at: Time.now)
  end
end
