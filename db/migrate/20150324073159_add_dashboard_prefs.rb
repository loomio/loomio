class AddDashboardPrefs < ActiveRecord::Migration
  def change
    add_column :users, :dashboard_sort, :string, default: 'sort_by_group', null: false
    add_column :users, :dashboard_filter, :string, default: 'show_all', null: false
  end
end
