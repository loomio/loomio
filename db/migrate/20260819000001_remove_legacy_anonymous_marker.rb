class RemoveLegacyAnonymousMarker < ActiveRecord::Migration[8.0]
  def change
    remove_column :polls, :legacy_anonymous, :boolean, default: false, null: false
  end
end
