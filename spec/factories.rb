FactoryGirl.define do
  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:group)}
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'password'
    time_zone "Pacific/Tarawa"
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :admin_user, class: User do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'password'
    is_admin {true}
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :group do
    sequence(:name) { Faker::Name.name }
    description 'A description for this group'
    privacy 'public'
    members_invitable_by 'members'
    after(:create) do |group, evaluator|
      user = FactoryGirl.create(:user)
      group.pending_invitations << FactoryGirl.create(:invitation, group: group)
      if group.parent.present?
        group.parent.admins << user
      end
      group.admins << user
    end
    max_size 300
    setup_completed_at 1.hour.ago
  end

  factory :discussion do
    association :author, :factory => :user
    group
    title { Faker::Name.name }
    description 'A description for this discussion. Should this be *rich*?'
    uses_markdown false
    after(:build) do |discussion|
      discussion.group.parent.add_member!(discussion.author) if discussion.group.parent
      discussion.group.add_member!(discussion.author)
    end
    after(:create) do |discussion|
      discussion.group.save
    end
  end

  factory :comment do
    user
    discussion
    body 'body of the comment'

    after(:build) do |comment|
      comment.discussion.group.parent.add_member!(comment.user) if comment.discussion.group.parent
      comment.discussion.group.add_member!(comment.user)
    end
    after(:create) do |comment|
      comment.discussion.group.save
    end
  end

  factory :motion do
    sequence(:name) { Faker::Name.name }
    association :author, :factory => :user
    description 'Fake description'
    discussion
    close_at_date '24-12-2044'
    close_at_time '16:00'
    close_at_time_zone 'Wellington'
    after(:build) do |motion|
      motion.group.parent.add_member!(motion.author) if motion.group.parent
      motion.group.add_member!(motion.author)
    end
    after(:create) do |motion|
      motion.group.save
    end
  end

  factory :current_motion, class: Motion do
    name { Faker::Name.name }
    association :author, :factory => :user
    description 'current motion'
    discussion
    close_at_date { 5.days.from_now.to_date.to_s }
    close_at_time '16:00'
    close_at_time_zone 'Wellington'
    after(:build) do |motion|
      motion.group.parent.add_member!(motion.author) if motion.group.parent
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

  factory :group_setup do
    group
    group_name Faker::Name.name
    group_description "My text outlining the group"
    privacy 'hidden'
    members_invitable_by 'admins'
    discussion_title Faker::Name.name
    discussion_description "My text outlining the discussion"
    motion_title {Faker::Name.name}
    motion_description "My text outlining the proposal"
    close_at_date (Date.today + 3.day).strftime("%d-%m-%Y")
    close_at_time "12:00"
    close_at_time_zone "Wellington"
    admin_email Faker::Internet.email
    recipients "#{Faker::Internet.email}, #{Faker::Internet.email}"
    message_subject "Welcome to our world"
    message_body "Please entertain me"
   end

  factory :vote do
    user
    motion
    ##  update below with Vote::POSITIONS content if changed###
    position %w[yes no abstain block].sample
    after(:build) do |vote|
      vote.motion.group.add_member!(vote.user)
    end
    after(:create) do |vote|
      vote.motion.group.save
    end
  end

  factory :group_request do
    name { Faker::Name.name }
    admin_name { Faker::Name.name }
    admin_email { Faker::Internet.email }
    payment_plan { 'subscription' }
  end

  factory :invitation do
    recipient_email { Faker::Internet.email }
    intent {'join_group'}
    association :inviter, factory: :user
  end

  factory :membership_request do
    introduction { Faker::Lorem.sentence(4) }
    group
  end

  factory :attachment do
    user
    filename { Faker::Name.name }
    location { Faker::Name.name }
  end
end
