require 'faker'

def seed_from_file(filename)
  seeds = File.readlines(File.join(__dir__, "./#{filename}.txt"))
  seeds.map { |seed| yield(seed.chomp) if block_given? }
end


BlacklistedPassword.delete_all
seed_from_file('password_blacklist') { |password| BlacklistedPassword.create(string: password) }

# if !Rails.env.test?
#   DefaultGroupCover.delete_all
#   seed_from_file('default_group_covers') { |url| DefaultGroupCover.store(url) }
# end

 # Julia's faker data to populate users

users = 10.times.map do
  User.create!( :name => Faker::Name.name,
                :email      => Faker::Internet.free_email,
                :password   => 'password3', 
                :gender => ["Female", "Male"].sample,
                :race => ["Native", "White", "Black", "Asian", "Pacific_Islander", "Other"].sample,
                :age => Faker::Number.between(16, 65))
end