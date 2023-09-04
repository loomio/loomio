class UpdateBlacklistedPasswords < ActiveRecord::Migration[7.0]
  def change
    attrs = File.readlines(Rails.root.join("db/password_blacklist.txt")).map(&:chomp).map do |pw|
      {string: pw}
    end

    BlacklistedPassword.delete_all
    BlacklistedPassword.insert_all(attrs, record_timestamps: false)
  end
end
