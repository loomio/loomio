passwords = File.readlines(File.join(__dir__, './password_blacklist.txt'))
  .map { |string| { string: string.chomp } }
BlacklistedPassword.create(passwords)
