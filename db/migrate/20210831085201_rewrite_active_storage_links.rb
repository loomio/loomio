require_relative "support/legacy_event_migration_service"

class RewriteActiveStorageLinks < ActiveRecord::Migration[6.1]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    LegacyEventMigrationService.rewrite_inline_images
    LegacyEventMigrationService.rewrite_attachment_links
  end
end
