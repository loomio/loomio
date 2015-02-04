class AddSearchVectors < ActiveRecord::Migration
  def change
    create_table :discussion_search_vectors do |t|
      t.belongs_to  :discussion
      t.tsvector :search_vector
    end

    create_table :motion_search_vectors do |t|
      t.belongs_to  :motion
      t.tsvector :search_vector
    end

    create_table :comment_search_vectors do |t|
      t.belongs_to  :comment
      t.tsvector :search_vector
    end

    execute("create index discussion_search_vector_index on discussion_search_vectors using gin(search_vector)")
    execute("create index motion_search_vector_index on motion_search_vectors using gin(search_vector)")
    execute("create index comment_search_vector_index on comment_search_vectors using gin(search_vector)")

    [Discussion, Motion, Comment].each do |model|
      puts "rebuilding search index for model: #{model.to_s}"
      progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                         progress_mark: "\e[32m/\e[0m",
                                         total: model.count )
      model.rebuild_search_index! { progress_bar.increment }

    end
  end
end
