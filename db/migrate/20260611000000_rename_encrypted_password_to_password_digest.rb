class RenameEncryptedPasswordToPasswordDigest < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :encrypted_password, :password_digest
  end
end
