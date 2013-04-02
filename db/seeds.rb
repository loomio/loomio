# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_helper_bot
  contact_user = User.find_or_initialize_by_email("contact@loom.io")
  if contact_user.new_record?
    contact_user.name = "Loomio Helper Bot"
    contact_user.password = "password"
    contact_user.save!
  end
end

def create_woc_options
  woc_options = WocOptions.first
  unless woc_options
    woc_options = WocOptions.new
    woc_options.example_discussion_url = 'https://www.loomio.org/woc'
    woc_options.save!
  end
end

create_helper_bot
create_woc_options
