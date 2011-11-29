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
  name { Faker::Name.name }
end

Motion.blueprint do
  name { Faker::Name.name }
  author { User.make! }
  group
  facilitator { User.make! }
  description { "Fake description" }
end

Membership.blueprint do
  user
  group
end
