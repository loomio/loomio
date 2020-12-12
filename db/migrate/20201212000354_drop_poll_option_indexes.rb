class DropPollOptionIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :poll_options, name: 'index_poll_options_on_poll_id_and_name'
    remove_index :poll_options, name: 'index_poll_options_on_poll_id_and_priority'
    remove_index :poll_options, name: 'index_poll_options_on_priority'
  end
end
