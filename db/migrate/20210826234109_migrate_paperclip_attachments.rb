class MigratePaperclipAttachments < ActiveRecord::Migration[6.0]
  def up
    raise "Please update to v2.11.13 before continuing to update to the latest version of loomio"
  end
end
