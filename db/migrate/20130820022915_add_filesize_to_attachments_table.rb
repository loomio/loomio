class AddFilesizeToAttachmentsTable < ActiveRecord::Migration
  def change
    add_column :attachments, :filesize, :integer
  end
end
