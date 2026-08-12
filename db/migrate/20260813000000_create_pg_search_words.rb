class CreatePgSearchWords < ActiveRecord::Migration[8.0]
  def up
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    create_table :pg_search_words, id: false do |t|
      t.text :word, null: false
      t.integer :document_count, null: false
    end

    execute "TRUNCATE pg_search_words"
    execute <<~SQL
      INSERT INTO pg_search_words (word, document_count)
      SELECT word, ndoc
      FROM ts_stat('SELECT ts_content FROM pg_search_documents')
      WHERE ndoc >= 3
        AND length(word) BETWEEN 4 AND 64
        AND word ~ '^[[:alpha:]][[:alpha:]''’_-]{3,63}$'
    SQL

    execute <<~SQL
      CREATE UNIQUE INDEX index_pg_search_words_on_word
        ON pg_search_words (word)
    SQL
    execute <<~SQL
      CREATE INDEX index_pg_search_words_on_word_trigram
        ON pg_search_words USING gin (word gin_trgm_ops)
    SQL
  end

  def down
    drop_table :pg_search_words, if_exists: true
  end
end
