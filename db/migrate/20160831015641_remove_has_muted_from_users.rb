class RemoveHasMutedFromUsers < ActiveRecord::Migration
  def change
    User.where(has_muted: true).each do |user|
      user.experienced!("mutingThread")
    end
    remove_column :users, :has_muted, :boolean
  end
end
