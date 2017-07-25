class IndexDiscussionsAndAhoyMesages < ActiveRecord::Migration
  def change
    add_index :discussions, [:is_deleted, :archived_at, :private], name: :index_discussions_visible
    add_index :ahoy_messages, :to
    add_index :ahoy_messages, :mailer
  end
end
