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
  name {Faker::Name.name}
end

Group.blueprint do
  name { Faker::Name.name }
end

Motion.blueprint do
  name { Faker::Name.name }
  group
  author { User.make }
  phase { 'voting' }
  description { "Fake description" }
end

Membership.blueprint do
  user
  group
end

Vote.blueprint do
  user
  motion
  position { Vote::POSITIONS.sample }
end
