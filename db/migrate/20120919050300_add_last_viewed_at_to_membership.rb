class AddLastViewedAtToMembership < ActiveRecord::Migration
  def up
    unless column_exists? :memberships, :last_viewed_at
      add_column :memberships, :last_viewed_at, :datetime, :default => Time.now()
    end
  end

  def down
    remove_column :memberships, :last_viewed_at
  end
end
