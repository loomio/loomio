class AddHasReadDashboardNoticeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_read_dashboard_notice, :boolean, :default => false,
      :null => false
  end
end
