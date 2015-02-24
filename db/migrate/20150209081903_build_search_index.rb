class BuildSearchIndex < ActiveRecord::Migration
  def change
    drop_table :motion_search_vectors
    drop_table :comment_search_vectors
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Discussion.count )
    SearchService.sync_without_delay! Discussion.all.pluck(:id) do
      progress_bar.increment
    end
  end
end
