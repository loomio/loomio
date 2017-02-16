class AddAvatarKindToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :avatar_kind, :string, default: 'initials', null: false
    add_column :visitors, :avatar_initials, :string
  end
end
