class AddIndexAhoyMessagesTo < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    execute('DELETE FROM ahoy_messages WHERE length("to") > 255')
    add_index :ahoy_messages, :to, algorithm: :concurrently
  end
end
