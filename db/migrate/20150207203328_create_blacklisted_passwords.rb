class CreateBlacklistedPasswords < ActiveRecord::Migration
  def up
    create_table :blacklisted_passwords do |t|
      t.string :string

      t.timestamps
    end
    add_index :blacklisted_passwords, :string, using: :hash

    passwords = File.readlines(File.join(__dir__, '../password_blacklist.txt'))
      .map { |string| { string: string.chomp } }
    BlacklistedPassword.create(passwords)
  end

  def down
  end
end
