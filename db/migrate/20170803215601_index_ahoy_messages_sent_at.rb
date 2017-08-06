class IndexAhoyMessagesSentAt < ActiveRecord::Migration
  def change
    add_index :ahoy_messages, :sent_at, order: :desc
  end
end
