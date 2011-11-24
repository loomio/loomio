require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end
#
User.blueprint do
  email { Faker::Internet.email }
  password { 'password'}
end

Group.blueprint do
  name { Faker::Name.name}
end

Membership.blueprint do
  user
  group
end
