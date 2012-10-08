
FactoryGirl.define do
  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:group)}
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'password'
  end

  factory :group do
    sequence(:name) { Faker::Name.name }
    association :creator, :factory => :user
    before(:create) do |group|
      group.parent.add_member!(group.creator) if group.parent
    end
  end

  factory :discussion do
    association :author, :factory => :user
    group
    title 'Title of discussion'
    description 'A description for this discussion'
    after(:build) do |discussion|
      discussion.group.add_member!(discussion.author)
    end
    after(:create) do |discussion|
      discussion.group.save
    end
  end

  factory :motion do
    sequence(:name) { Faker::Name.name }
    association :author, :factory => :user
    phase 'voting'
    description 'Fake description'
    discussion
    after(:build) do |motion|
      motion.group.add_member!(motion.author)
    end
    after(:create) do |motion|
      motion.group.save
    end
  end

  factory :motion_read_log do
    user
    motion
  end

  factory :vote do
    user
    motion
    position Vote::POSITIONS.sample
    after(:build) do |vote|
      vote.motion.group.add_member!(vote.user)
    end
    after(:create) do |vote|
      vote.motion.group.save
    end
  end

  factory :group_request do
    name Faker::Name.name
    expected_size 50
    description "MyText"
    admin_email Faker::Internet.email
  end
end
