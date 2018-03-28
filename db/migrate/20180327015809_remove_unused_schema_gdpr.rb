class RemoveUnusedSchemaGdpr < ActiveRecord::Migration[5.1]
  def change
    remove_column :comments, :liker_ids_and_names
    drop_table    :attachments
    drop_table    :contact_messages
    drop_table    :group_hierarchies
    drop_table    :poll_references
  end
end
