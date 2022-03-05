class DropCounterSequences < ActiveRecord::Migration[6.1]
  def change
    execute("SELECT relname FROM pg_class where (relname ilike 'discussion_%_sequence_id_seq' or relname ilike 'event_%_position_seq')").each do |row|
      execute "DROP SEQUENCE IF EXISTS #{row['relname']}"
    end
  end
end
