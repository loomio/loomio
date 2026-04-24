# Rails Pulse Database Schema
# This file contains the complete schema for Rails Pulse tables
# Load with: rails db:schema:load_rails_pulse or db:prepare

RailsPulse::Schema = lambda do |connection|
  adapter = connection.adapter_name.downcase
  # Skip if all tables already exist to prevent conflicts
  required_tables = [ :rails_pulse_routes, :rails_pulse_queries, :rails_pulse_requests, :rails_pulse_operations, :rails_pulse_jobs, :rails_pulse_job_runs, :rails_pulse_summaries ]

  # Check which tables already exist
  existing_tables = required_tables.select { |table| connection.table_exists?(table) }
  missing_tables = required_tables - existing_tables

  # Always log for transparency (not just in CI)
  if existing_tables.any?
    puts "[RailsPulse::Schema] Existing tables detected: #{existing_tables.join(', ')}"
  end

  if missing_tables.any?
    puts "[RailsPulse::Schema] Creating missing tables: #{missing_tables.join(', ')}"
  end

  # If all tables exist, skip creation entirely
  if missing_tables.empty?
    puts "[RailsPulse::Schema] All Rails Pulse tables already exist. Skipping schema load."
    return
  end

  unless connection.table_exists?(:rails_pulse_routes)
    connection.create_table :rails_pulse_routes do |t|
      t.string :method, null: false, comment: "HTTP method (e.g., GET, POST)"
      t.string :path, null: false, comment: "Request path (e.g., /posts/index)"
      t.text :tags, comment: "JSON array of tags for filtering and categorization"
      t.timestamps
    end

    connection.add_index :rails_pulse_routes, [ :method, :path ], unique: true, name: "index_rails_pulse_routes_on_method_and_path"
    connection.add_index :rails_pulse_routes, :path, name: "index_rails_pulse_routes_on_path"
  end

  unless connection.table_exists?(:rails_pulse_queries)
    connection.create_table :rails_pulse_queries do |t|
      t.string :hashed_sql, limit: 32, null: false, comment: "MD5 hash of normalized SQL for indexing"
      t.text :normalized_sql, null: false, comment: "Normalized SQL query string (e.g., SELECT * FROM users WHERE id = ?)"
      t.datetime :analyzed_at, comment: "When query analysis was last performed"
      t.text :explain_plan, comment: "EXPLAIN output from actual SQL execution"
      t.text :issues, comment: "JSON array of detected performance issues"
      t.text :metadata, comment: "JSON object containing query complexity metrics"
      t.text :query_stats, comment: "JSON object with query characteristics analysis"
      t.text :backtrace_analysis, comment: "JSON object with call chain and N+1 detection"
      t.text :index_recommendations, comment: "JSON array of database index recommendations"
      t.text :n_plus_one_analysis, comment: "JSON object with enhanced N+1 query detection results"
      t.text :suggestions, comment: "JSON array of optimization recommendations"
      t.text :tags, comment: "JSON array of tags for filtering and categorization"
      t.timestamps
    end

    connection.add_index :rails_pulse_queries, :hashed_sql, unique: true, name: "index_rails_pulse_queries_on_hashed_sql"
  end

  unless connection.table_exists?(:rails_pulse_requests)
    connection.create_table :rails_pulse_requests do |t|
      t.references :route, null: false, foreign_key: { to_table: :rails_pulse_routes }, comment: "Link to the route"
      t.decimal :duration, precision: 15, scale: 6, null: false, comment: "Total request duration in milliseconds"
      t.integer :status, null: false, comment: "HTTP status code (e.g., 200, 500)"
      t.boolean :is_error, null: false, default: false, comment: "True if status >= 500"
      t.string :request_uuid, null: false, comment: "Unique identifier for the request (e.g., UUID)"
      t.string :controller_action, comment: "Controller and action handling the request (e.g., PostsController#show)"
      t.timestamp :occurred_at, null: false, comment: "When the request started"
      t.text :tags, comment: "JSON array of tags for filtering and categorization"
      t.timestamps
    end

    connection.add_index :rails_pulse_requests, :occurred_at, name: "index_rails_pulse_requests_on_occurred_at"
    connection.add_index :rails_pulse_requests, :request_uuid, unique: true, name: "index_rails_pulse_requests_on_request_uuid"
    connection.add_index :rails_pulse_requests, [ :route_id, :occurred_at ], name: "index_rails_pulse_requests_on_route_id_and_occurred_at"
  end

  unless connection.table_exists?(:rails_pulse_jobs)
    connection.create_table :rails_pulse_jobs do |t|
      t.string :name, null: false, comment: "Job class name"
      t.string :queue_name, comment: "Default queue"
      t.text :description, comment: "Optional description"
      t.integer :runs_count, null: false, default: 0, comment: "Cache of total runs"
      t.integer :failures_count, null: false, default: 0, comment: "Cache of failed runs"
      t.integer :retries_count, null: false, default: 0, comment: "Cache of retried runs"
      t.decimal :avg_duration, precision: 15, scale: 6, comment: "Average duration in milliseconds"
      t.text :tags, comment: "JSON array of tags"
      t.timestamps
    end

    connection.add_index :rails_pulse_jobs, :name, unique: true, name: "index_rails_pulse_jobs_on_name"
    connection.add_index :rails_pulse_jobs, :queue_name, name: "index_rails_pulse_jobs_on_queue"
    connection.add_index :rails_pulse_jobs, :runs_count, name: "index_rails_pulse_jobs_on_runs_count"
  end

  unless connection.table_exists?(:rails_pulse_job_runs)
    connection.create_table :rails_pulse_job_runs do |t|
      t.references :job, null: false, foreign_key: { to_table: :rails_pulse_jobs }, comment: "Link to job definition"
      t.string :run_id, null: false, comment: "Adapter specific run id"
      t.decimal :duration, precision: 15, scale: 6, comment: "Execution duration in milliseconds"
      t.string :status, null: false, comment: "Execution status"
      t.string :error_class, comment: "Error class name"
      t.text :error_message, comment: "Error message"
      t.integer :attempts, null: false, default: 0, comment: "Retry attempts"
      t.timestamp :occurred_at, null: false, comment: "When the job started"
      t.timestamp :enqueued_at, comment: "When the job was enqueued"
      t.text :arguments, comment: "Serialized arguments"
      t.string :adapter, comment: "Queue adapter"
      t.text :tags, comment: "Execution tags"
      t.timestamps
    end

    connection.add_index :rails_pulse_job_runs, :run_id, unique: true, name: "index_rails_pulse_job_runs_on_run_id"
    connection.add_index :rails_pulse_job_runs, [ :job_id, :occurred_at ], name: "index_rails_pulse_job_runs_on_job_and_occurred"
    connection.add_index :rails_pulse_job_runs, :occurred_at, name: "index_rails_pulse_job_runs_on_occurred_at"
    connection.add_index :rails_pulse_job_runs, :status, name: "index_rails_pulse_job_runs_on_status"
    connection.add_index :rails_pulse_job_runs, [ :job_id, :status ], name: "index_rails_pulse_job_runs_on_job_and_status"
  end

  unless connection.table_exists?(:rails_pulse_operations)
    connection.create_table :rails_pulse_operations do |t|
      t.references :request, null: true, foreign_key: { to_table: :rails_pulse_requests }, comment: "Link to the request"
      t.references :job_run, null: true, foreign_key: { to_table: :rails_pulse_job_runs }, comment: "Link to a background job execution"
      t.references :query, foreign_key: { to_table: :rails_pulse_queries }, index: false, comment: "Link to the normalized SQL query"
      t.string :operation_type, null: false, comment: "Type of operation (e.g., database, view, gem_call)"
      t.string :label, null: false, comment: "Descriptive name (e.g., SELECT FROM users WHERE id = 1, render layout)"
      t.decimal :duration, precision: 15, scale: 6, null: false, comment: "Operation duration in milliseconds"
      t.string :codebase_location, comment: "File and line number (e.g., app/models/user.rb:25)"
      t.float :start_time, null: false, default: 0.0, comment: "Operation start time in milliseconds"
      t.timestamp :occurred_at, null: false, comment: "When the request started"
      t.timestamps
    end

    connection.add_index :rails_pulse_operations, :operation_type, name: "index_rails_pulse_operations_on_operation_type"
    connection.add_index :rails_pulse_operations, [ :query_id, :occurred_at ], name: "index_rails_pulse_operations_on_query_and_time"
    connection.add_index :rails_pulse_operations, [ :query_id, :duration, :occurred_at ], name: "index_rails_pulse_operations_query_performance"
    connection.add_index :rails_pulse_operations, [ :occurred_at, :duration, :operation_type ], name: "index_rails_pulse_operations_on_time_duration_type"

    if adapter.include?("postgres") || adapter.include?("mysql")
      connection.add_check_constraint :rails_pulse_operations,
        "(request_id IS NOT NULL OR job_run_id IS NOT NULL)",
        name: "rails_pulse_operations_request_or_job_run"
    end
  end

  unless connection.table_exists?(:rails_pulse_summaries)
    connection.create_table :rails_pulse_summaries do |t|
      # Time fields
      t.datetime :period_start, null: false, comment: "Start of the aggregation period"
      t.datetime :period_end, null: false, comment: "End of the aggregation period"
      t.string :period_type, null: false, comment: "Aggregation period type: hour, day, week, month"

      # Polymorphic association to handle both routes and queries
      t.references :summarizable, polymorphic: true, null: false, index: false, comment: "Link to Route or Query"
      # This creates summarizable_type (e.g., 'RailsPulse::Route', 'RailsPulse::Query')
      # and summarizable_id (route_id or query_id)

      # Universal metrics
      t.integer :count, default: 0, null: false, comment: "Total number of requests/operations"
      t.float :avg_duration, comment: "Average duration in milliseconds"
      t.float :min_duration, comment: "Minimum duration in milliseconds"
      t.float :max_duration, comment: "Maximum duration in milliseconds"
      t.float :p50_duration, comment: "50th percentile duration"
      t.float :p95_duration, comment: "95th percentile duration"
      t.float :p99_duration, comment: "99th percentile duration"
      t.float :total_duration, comment: "Total duration in milliseconds"
      t.float :stddev_duration, comment: "Standard deviation of duration"

      # Request/Route specific metrics
      t.integer :error_count, default: 0, comment: "Number of error responses (5xx)"
      t.integer :success_count, default: 0, comment: "Number of successful responses"
      t.integer :status_2xx, default: 0, comment: "Number of 2xx responses"
      t.integer :status_3xx, default: 0, comment: "Number of 3xx responses"
      t.integer :status_4xx, default: 0, comment: "Number of 4xx responses"
      t.integer :status_5xx, default: 0, comment: "Number of 5xx responses"

      t.timestamps
    end

    # Unique constraint and indexes for summaries
    connection.add_index :rails_pulse_summaries, [ :summarizable_type, :summarizable_id, :period_type, :period_start ],
            unique: true,
            name: "idx_pulse_summaries_unique"
    connection.add_index :rails_pulse_summaries, [ :period_type, :period_start ], name: "index_rails_pulse_summaries_on_period"
    connection.add_index :rails_pulse_summaries, :created_at, name: "index_rails_pulse_summaries_on_created_at"
    connection.add_index :rails_pulse_summaries, :summarizable_id, name: "index_rails_pulse_summaries_on_summarizable_id"
    connection.add_index :rails_pulse_summaries, :period_start, name: "index_rails_pulse_summaries_on_period_start"
  end

  # Add indexes to existing tables for efficient aggregation
  unless connection.index_exists?(:rails_pulse_requests, [ :created_at, :route_id ], name: "idx_requests_for_aggregation")
    connection.add_index :rails_pulse_requests, [ :created_at, :route_id ], name: "idx_requests_for_aggregation"
  end

  unless connection.index_exists?(:rails_pulse_operations, [ :created_at, :query_id ], name: "idx_operations_for_aggregation")
    connection.add_index :rails_pulse_operations, [ :created_at, :query_id ], name: "idx_operations_for_aggregation"
  end

  # Log successful creation
  created_tables = required_tables.select { |table| connection.table_exists?(table) }
  newly_created = created_tables - existing_tables
  if newly_created.any?
    puts "[RailsPulse::Schema] Successfully created tables: #{newly_created.join(', ')}"
  end
end

if defined?(RailsPulse::ApplicationRecord)
  RailsPulse::Schema.call(RailsPulse::ApplicationRecord.connection)
end
