class AddAuthorIdToRecordEdits < ActiveRecord::Migration
  def up
    add_column :record_edits, :author_id, :integer
  end
end
