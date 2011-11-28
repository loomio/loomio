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

# Motion.blueprint do
#   name { Faker::Name.name }
#   author
#   facilitator
#   description "Fake description"
# end

Group.blueprint do
  name { Faker::Name.name }
end

Membership.blueprint do
  user
  group
end
