class UpdateAdminCountsForGroups < ActiveRecord::Migration
  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Group.count )
    Group.find_each(batch_size: 100) { |g| g.update_admin_memberships_count && progress_bar.increment }
  end
end
