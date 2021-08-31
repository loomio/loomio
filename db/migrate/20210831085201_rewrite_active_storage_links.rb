class RewriteActiveStorageLinks < ActiveRecord::Migration[6.1]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    MigrateEventsService.rewrite_inline_images
    MigrateEventsService.rewrite_attachment_links
  end
end
