attrs = File.readlines(Rails.root.join("db/password_blacklist.txt")).map(&:chomp).map do |pw|
  {string: pw}
end

BlacklistedPassword.delete_all
BlacklistedPassword.insert_all(attrs, record_timestamps: false)
