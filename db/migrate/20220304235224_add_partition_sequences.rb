class AddPartitionSequences < ActiveRecord::Migration[6.1]
  def up
    execute "CREATE TABLE IF NOT EXISTS partition_sequences (key TEXT, id INTEGER, counter INTEGER DEFAULT 0, PRIMARY KEY(key, id))"
  end
  def down
    execute "DROP TABLE partition_sequences"
  end
end
