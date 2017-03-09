FactoryGirl.define do

  factory :blog_story do
    title "MyString"
    url "MyString"
    image_url "MyString"
    published_at "2015-11-18 14:28:30"
  end

  factory :blacklisted_password do
    string "MyString"
  end

  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:group)}
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    angular_ui_enabled false
    password 'complex_password'
    time_zone "Pacific/Tarawa"

    after(:build) do |user|
      user.generate_username
    end
  end

  factory :admin_user, class: User do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'complex_password'
    is_admin {true}
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :contact do
    user
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    source 'gmail'
  end

  factory :group do
    sequence(:name) { Faker::Name.name }
    description 'A description for this group'
    group_privacy 'open'
    discussion_privacy_options 'public_or_private'
    members_can_add_members true
    after(:create) do |group, evaluator|
      user = FactoryGirl.create(:user)
      #group.pending_invitations << FactoryGirl.create(:invitation, invitable: group)
      if group.parent.present?
        group.parent.admins << user
      end
      group.admins << user
      group.save!
    end
  end

  factory :discussion do
    association :author, :factory => :user
    group
    title { Faker::Name.name }
    description 'A description for this discussion. Should this be *rich*?'
    uses_markdown false
    private true
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

  factory :comment_vote do
    comment
    user
  end

  factory :motion do
    sequence(:name) { Faker::Name.name }
    association :author, factory: :user
    description 'Fake description'
    discussion

    #after(:build) do |motion|
      #motion.group.parent.add_member!(motion.author) if motion.group.parent
      #motion.group.add_member!(motion.author)
    #end

    after(:create) do |motion|
      motion.group.add_member!(motion.author)
    end
  end

  factory :current_motion, class: Motion do
    name { Faker::Name.name }
    association :author, :factory => :user
    description 'current motion'
    discussion
    closing_at { 5.days.from_now }
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
    members_can_add_members false
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
    statement "A short statement explaining my position."
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
  end

  factory :invitation do
    recipient_email { Faker::Internet.email }
    intent {'join_group'}
    association :inviter, factory: :user
  end

  factory :membership_request do
    introduction { Faker::Lorem.sentence(4) }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    group
  end

  factory :attachment do
    user
    filename { Faker::Name.name }
    location { Faker::Company.logo }
  end

  factory :translation do
    language 'en'
    fields {{ body: 'Successful translation' }}
  end

  factory :search_result do
    discussion
    motion
    comment
    discussion_blurb "discussion blurb"
    motion_blurb "motion blurb"
    comment_blurb "comment blurb"
    priority 1.0
    query "test query"
  end

  factory :webhook do
    association :hookable, factory: :discussion
    uri { "www.test.com" }
    kind :slack
    event_types { ['motion_closing_soon', 'new_motion', 'motion_outcome_created'] }
  end

  factory :default_group_cover do
    cover_photo_file_name { "test.jpg" }
    cover_photo_file_size { 10000 }
    cover_photo_content_type { "image/jpeg" }
    cover_photo_updated_at { 10.days.ago }
  end

  factory :draft do
    user
    association :draftable, factory: :discussion
    payload {{ payload: 'payload' }}
  end

  factory :application, class: OauthApplication do
    name "More like BROAuth, am I right?"
    association :owner, factory: :user
    redirect_uri "https://www.loomio.org"
  end

  factory :access_token, class: Doorkeeper::AccessToken do
    resource_owner_id { create(:user).id }
    association :application, factory: :application
  end

  factory :poll_option do
    name "Plan A"
  end

  factory :poll do
    poll_type "poll"
    title "This is a poll"
    details "with a description"
    association :author, factory: :user
    poll_option_names ["engage"]

    after(:build) { |poll| poll.community_of_type(:email, build: true).save }
  end

  factory :poll_proposal, class: Poll do
    poll_type "proposal"
    title "This is a proposal"
    details "with a description"
    association :author, factory: :user
    poll_option_names %w[agree abstain disagree block]

    after(:build) { |poll| poll.community_of_type(:email, build: true) }
  end

  factory :outcome do
    poll
    association :author, factory: :user
    statement "An outcome"
  end

  factory :stance do
    poll
    association :participant, factory: :user
  end

  factory :stance_choice do
    poll_option
  end

  factory :community, class: Communities::Base do
    community_type 'test'
  end

  factory :public_community, class: Communities::Public
  factory :email_community, class: Communities::Email

  factory :loomio_group_community, class: Communities::LoomioGroup do
    group
  end

  factory :visitor do
    association :community, factory: :public_community
    name "John Doe"
    email "john@doe.com"
  end

end
