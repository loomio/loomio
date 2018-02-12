class AddHandleToGroups < ActiveRecord::Migration[5.1]
  def change
    rename_column :groups, :subdomain, :handle
  end
end
