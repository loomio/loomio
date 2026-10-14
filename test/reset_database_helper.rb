module ResetDatabaseHelper
  module_function

  def reset_database
    conn = ActiveRecord::Base.connection
    tables = conn.tables - %w[ar_internal_metadata schema_migrations]
    # A running Solid Cable poller remembers the last message ID. Restarting
    # that sequence between browser scenarios makes it miss new messages.
    cable_tables = tables & %w[solid_cable_messages]
    quoted_tables = (tables - cable_tables).map { |table| conn.quote_table_name(table) }
    conn.execute("TRUNCATE TABLE #{quoted_tables.join(', ')} RESTART IDENTITY CASCADE")
    cable_tables.each { |table| conn.execute("TRUNCATE TABLE #{conn.quote_table_name(table)}") }
  end
end
