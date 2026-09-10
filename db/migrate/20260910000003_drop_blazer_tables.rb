class DropBlazerTables < ActiveRecord::Migration[8.1]
  def change
    remove_column :groups, :cohort_id, :integer, if_exists: true
    remove_column :groups, :default_group_cover_id, :integer, if_exists: true

    drop_table :group_surveys, if_exists: true do |t|
      t.string :category
      t.string :declaration
      t.string :desired_feature
      t.integer :group_id, null: false
      t.string :location
      t.text :misc
      t.text :purpose
      t.string :referrer
      t.string :role
      t.string :segment
      t.string :size
      t.string :usage
      t.string :website
      t.timestamps null: false
      t.index :group_id
      t.foreign_key :groups, on_delete: :cascade
    end

    drop_table :cohorts, id: :serial, if_exists: true do |t|
      t.date :start_on
      t.date :end_on
    end

    drop_table :default_group_covers, id: :serial, if_exists: true do |t|
      t.string :cover_photo_content_type
      t.string :cover_photo_file_name
      t.integer :cover_photo_file_size
      t.datetime :cover_photo_updated_at
      t.timestamps
    end

    drop_table :oauth_access_grants, id: :serial, if_exists: true do |t|
      t.integer :application_id, null: false
      t.datetime :created_at, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.integer :resource_owner_id, null: false
      t.datetime :revoked_at
      t.string :scopes
      t.string :token, null: false
      t.index :token, unique: true
    end

    drop_table :oauth_access_tokens, id: :serial, if_exists: true do |t|
      t.integer :application_id
      t.datetime :created_at, null: false
      t.integer :expires_in
      t.string :refresh_token
      t.integer :resource_owner_id
      t.datetime :revoked_at
      t.string :scopes
      t.string :token, null: false
      t.index :refresh_token, unique: true
      t.index :resource_owner_id
      t.index :token, unique: true
    end

    drop_table :oauth_applications, id: :serial, if_exists: true do |t|
      t.datetime :created_at
      t.string :logo_content_type
      t.string :logo_file_name
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.string :name, null: false
      t.integer :owner_id
      t.string :owner_type
      t.text :redirect_uri, null: false
      t.string :scopes, default: "", null: false
      t.string :secret, null: false
      t.string :uid, null: false
      t.datetime :updated_at
      t.index [:owner_id, :owner_type]
      t.index :uid, unique: true
    end

    drop_table :blazer_checks, if_exists: true do |t|
      t.references :creator
      t.references :query
      t.string :state
      t.string :schedule
      t.text :emails
      t.text :slack_channels
      t.string :check_type
      t.text :message
      t.datetime :last_run_at
      t.timestamps null: false
    end

    drop_table :blazer_dashboard_queries, if_exists: true do |t|
      t.references :dashboard
      t.references :query
      t.integer :position
      t.timestamps null: false
    end

    drop_table :blazer_dashboards, if_exists: true do |t|
      t.references :creator
      t.string :name
      t.timestamps null: false
    end

    drop_table :blazer_audits, if_exists: true do |t|
      t.references :user
      t.references :query
      t.text :statement
      t.string :data_source
      t.datetime :created_at
    end

    drop_table :blazer_queries, if_exists: true do |t|
      t.references :creator
      t.string :name
      t.text :description
      t.text :statement
      t.string :data_source
      t.string :status
      t.timestamps null: false
    end
  end
end
