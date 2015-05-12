class RemoveDashboardPreferences < ActiveRecord::Migration
  def change
    remove_column :users, :dashboard_sort, :string
    remove_column :users, :dashboard_filter, :string 
  end
end
