class RebuildSearchIndexes < ActiveRecord::Migration
  def change
    [Discussion, Motion, Comment].each do |model|
      puts "rebuilding search index for model: #{model.to_s}"
      progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                         progress_mark: "\e[32m/\e[0m",
                                         total: model.count )
      model.rebuild_search_index! { progress_bar.increment }

    end
  end
end
