class RenameEncryptedPasswordToPasswordDigest < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:users, :encrypted_password) && !column_exists?(:users, :password_digest)
      rename_column :users, :encrypted_password, :password_digest
    end
  end

  def down
    if column_exists?(:users, :password_digest) && !column_exists?(:users, :encrypted_password)
      rename_column :users, :password_digest, :encrypted_password
    end
  end
end
