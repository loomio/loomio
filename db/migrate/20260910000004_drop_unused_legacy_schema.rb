class DropUnusedLegacySchema < ActiveRecord::Migration[8.1]
  def change
    drop_table :active_admin_comments, if_exists: true do |t|
      t.bigint :author_id
      t.string :author_type
      t.text :body
      t.timestamps null: false
      t.string :namespace
      t.bigint :resource_id
      t.string :resource_type
      t.index [ :author_type, :author_id ]
      t.index [ :resource_type, :resource_id ]
    end

    drop_table :attachments, id: :serial, if_exists: true do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.integer :comment_id
      t.timestamps null: false
      t.string :file_content_type
      t.string :file_file_name
      t.integer :file_file_size
      t.datetime :file_updated_at
      t.string :filename, limit: 255
      t.integer :filesize
      t.text :location
      t.boolean :migrated_to_document, default: false, null: false
      t.integer :user_id
      t.index [ :attachable_id, :attachable_type ]
      t.index :comment_id
      t.index :user_id
    end

    drop_table :user_deactivation_responses, id: :serial, if_exists: true do |t|
      t.text :body
      t.integer :user_id
    end

    drop_table :webhooks, if_exists: true do |t|
      t.integer :actor_id
      t.integer :author_id
      t.datetime :created_at
      t.jsonb :event_kinds, default: [], null: false
      t.string :format, default: "markdown"
      t.integer :group_id, null: false
      t.boolean :include_body, default: false
      t.boolean :include_subgroups, default: false, null: false
      t.boolean :is_broken, default: false, null: false
      t.datetime :last_used_at
      t.string :name, null: false
      t.string :permissions, default: [], null: false, array: true
      t.string :token
      t.datetime :updated_at
      t.string :url
      t.index :group_id
      t.foreign_key :groups, on_delete: :cascade
    end

    remove_column :comments, :attachments_count, :integer, default: 0, null: false, if_exists: true
    remove_column :comments, :comment_votes_count, :integer, default: 0, null: false, if_exists: true

    remove_column :discussions, :iframe_src, :string, limit: 255, if_exists: true
    remove_column :discussions, :importance, :integer, default: 0, null: false, if_exists: true
    remove_column :discussions, :last_comment_at, :datetime, if_exists: true

    remove_column :groups, :category_id, :integer, if_exists: true
    remove_column :groups, :closed_motions_count, :integer, default: 0, null: false, if_exists: true
    remove_column :groups, :cover_photo_content_type, :string, limit: 255, if_exists: true
    remove_column :groups, :cover_photo_file_name, :string, limit: 255, if_exists: true
    remove_column :groups, :cover_photo_file_size, :integer, if_exists: true
    remove_column :groups, :cover_photo_updated_at, :datetime, if_exists: true
    remove_column :groups, :invitations_count, :integer, default: 0, null: false, if_exists: true
    remove_column :groups, :is_referral, :boolean, default: false, null: false, if_exists: true
    remove_column :groups, :logo_content_type, :string, limit: 255, if_exists: true
    remove_column :groups, :logo_file_name, :string, limit: 255, if_exists: true
    remove_column :groups, :logo_file_size, :integer, if_exists: true
    remove_column :groups, :logo_updated_at, :datetime, if_exists: true
    remove_column :groups, :proposal_outcomes_count, :integer, default: 0, null: false, if_exists: true

    remove_column :memberships, :inbox_position, :integer, default: 0, if_exists: true
    remove_column :memberships, :invitation_id, :integer, if_exists: true
    remove_column :memberships, :saml_session_expires_at, :datetime, if_exists: true

    remove_column :poll_templates, :atttachments, :jsonb, default: [], null: false, if_exists: true

    remove_column :polls, :matrix_counts, :jsonb, default: [], null: false, if_exists: true
    remove_column :polls, :multiple_choice, :boolean, default: false, null: false, if_exists: true
    remove_column :polls, :stance_data, :jsonb, default: {}, if_exists: true

    remove_column :tags, :org_taggings_count, :integer, default: 0, null: false, if_exists: true
    remove_column :topic_readers, :participating, :boolean, default: false, null: false, if_exists: true

    remove_column :users, :email_catch_up, :boolean, default: true, null: false, if_exists: true
    remove_column :users, :facebook_community_id, :integer, if_exists: true
    remove_column :users, :slack_community_id, :integer, if_exists: true
    remove_column :users, :uploaded_avatar_content_type, :string, limit: 255, if_exists: true
    remove_column :users, :uploaded_avatar_file_name, :string, limit: 255, if_exists: true
    remove_column :users, :uploaded_avatar_file_size, :integer, if_exists: true
    remove_column :users, :uploaded_avatar_updated_at, :datetime, if_exists: true
  end
end
