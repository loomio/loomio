class AddPgTrgmIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    enable_extension :pg_trgm

    add_index :users,    :name,     using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_users_on_name_trgm
    add_index :users,    :username, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_users_on_username_trgm
    add_index :users,    :email,    using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_users_on_email_trgm

    add_index :groups,   :name,        using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_groups_on_name_trgm
    add_index :groups,   :handle,      using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_groups_on_handle_trgm
    add_index :groups,   :description, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_groups_on_description_trgm

    add_index :discussions, :title, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_discussions_on_title_trgm
    add_index :polls,       :title, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_polls_on_title_trgm
    add_index :documents,   :title, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_documents_on_title_trgm

    add_index :active_storage_blobs, :filename, using: :gin, opclass: :gin_trgm_ops, algorithm: :concurrently, name: :index_active_storage_blobs_on_filename_trgm
  end
end
