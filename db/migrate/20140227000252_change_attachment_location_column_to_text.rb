class ChangeAttachmentLocationColumnToText < ActiveRecord::Migration
  def up
   change_column :attachments, :location, :text
  end

  def down
   change_column :attachments, :location, :string
  end
end
