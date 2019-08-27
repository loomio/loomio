class AllowNullOnUserAvatarKind < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :avatar_kind, :string, null: true, default: nil
  end
end
