module HasVersionsCount
  extend ActiveSupport::Concern

  included do
    # PaperTrail creates versions in after_create/after_update; after_save sees
    # the new version and keeps counts current before events are published.
    after_save :update_versions_count
  end

  def update_versions_count
    update_column(:versions_count, versions.count)
  end
end
