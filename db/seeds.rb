# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

contact_user = User.find_or_initialize_by_email("contact@loom.io")
contact_user.name = "Loomio Helper Bot"
if contact_user.new_record?
  contact_user.password = "password"
end
contact_user.save!

one_user = User.find_or_initialize_by_email("paul@psweb.co.nz")
one_user.name = "tix"
one_user.admin = true
if one_user.new_record?
  one_user.password = "password"
end
one_user.save!

two_user = User.find_or_initialize_by_email("tixtwo@example.com")
two_user.name = "tixtwo"
if two_user.new_record?
  two_user.password = "password"
end
two_user.save!

