def seed_from_file(filename)
  seeds = File.readlines(File.join(__dir__, "./#{filename}.txt"))
  seeds.map { |seed| yield(seed.chomp) if block_given? }
end

BlacklistedPassword.delete_all
DefaultGroupCover.delete_all

seed_from_file('password_blacklist') { |password| BlacklistedPassword.create(string: password) }
seed_from_file('default_group_covers') { |url| DefaultGroupCover.store(url) }
