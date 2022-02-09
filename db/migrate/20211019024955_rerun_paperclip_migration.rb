class RerunPaperclipMigration < ActiveRecord::Migration[6.1]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    raise "Please update to v2.11.13 before continuing to update to the latest version of loomio"
  end
end
