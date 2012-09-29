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

