class AddDiscussionReadersUniqueConstaint < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute "DELETE FROM discussion_readers as dr1
                                              USING discussion_readers as dr2
                                              WHERE dr1.id > dr2.id
                                                 AND dr1.user_id = dr2.user_id
                                                 AND dr1.discussion_id = dr2.discussion_id;"
    if index_exists?(:discussion_readers,  name: "index_discussion_read_logs_on_user_id_and_discussion_id")
      remove_index :discussion_readers,  name: "index_discussion_read_logs_on_user_id_and_discussion_id"
    end
    unless index_exists?(:discussion_readers, [:user_id, :discussion_id])
      add_index :discussion_readers, [:user_id, :discussion_id], unique: true
    end
  end
end
