class AddGuestBooleanToDiscussionReadersAndStances < ActiveRecord::Migration[7.0]
  def change
    add_column :discussion_readers, :guest, :boolean, null: false, default: false
    add_column :stances, :guest, :boolean, null: false, default: false
    add_index :discussion_readers, :guest, name: 'discussion_readers_guests', where: "(guest = TRUE)"
    add_index :stances, :guest, name: 'stances_guests', where: "(guest = TRUE)"

    # FIXME add/run migration to convert existing guest records to guest = true
  end
end
