module ResetDatabaseHelper
  module_function

  def reset_database
    conn = ActiveRecord::Base.connection
    tables = conn.tables - %w[ar_internal_metadata schema_migrations]
    quoted_tables = tables.map { |table| conn.quote_table_name(table) }
    conn.execute("TRUNCATE TABLE #{quoted_tables.join(', ')} RESTART IDENTITY CASCADE")
  end
end
