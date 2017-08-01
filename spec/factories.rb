FactoryGirl.define do

  factory :blacklisted_password do
    string "MyString"
  end

  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:formal_group)}
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    angular_ui_enabled false
    password 'complex_password'
    time_zone "Pacific/Tarawa"
    email_verified true

    after(:build) do |user|
      user.generate_username
    end
  end

  factory :login_token do
    user
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

  factory :slack_identity, class: Identities::Slack do
    user
    identity_type "slack"
    access_token "dat_access"
    uid "U123"
    sequence(:name) { Faker::Name.name }
    sequence(:email) { Faker::Internet.email }
    custom_fields {{
      slack_team_id: "T123",
      slack_team_name: "Hojo's Honchos"
    }}
  end

  factory :facebook_identity, class: Identities::Facebook do
    user
    identity_type "facebook"
    access_token "access_dat"
    uid "U123"
    sequence(:name) { Faker::Name.name }
    sequence(:email) { Faker::Internet.email }
    custom_fields { { facebook_group_id: "G123" } }
  end

  factory :contact do
    user
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    source 'gmail'
  end

  factory :formal_group do
    sequence(:name) { Faker::Name.name }
    description 'A description for this group'
    group_privacy 'open'
    discussion_privacy_options 'public_or_private'
    members_can_add_members true
    after(:create) do |group, evaluator|
      user = FactoryGirl.create(:user)
      if group.parent.present?
        group.parent.admins << user
      end
      group.admins << user
      group.save!
    end
  end

  factory :guest_group do
    group_privacy 'closed'
  end

  factory :group_identity do
    association :group, factory: :formal_group
    association :identity, factory: :slack_identity
  end

  factory :discussion do
    association :author, :factory => :user
    association :group, :factory => :formal_group
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

  factory :invitation do
    recipient_email { Faker::Internet.email }
    single_use true
    intent {'join_group'}
    association :inviter, factory: :user
  end

  factory :shareable_invitation, class: Invitation do
    single_use false
    intent 'join_group'
    association :inviter, factory: :user
  end

  factory :membership_request do
    introduction { Faker::Lorem.sentence(4) }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    association :group, factory: :formal_group
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
    association :guest_group, factory: :guest_group
    poll_option_names ["engage"]
  end

  factory :poll_proposal, class: Poll do
    poll_type "proposal"
    title "This is a proposal"
    details "with a description"
    association :author, factory: :user
    poll_option_names %w[agree abstain disagree block]
    association :guest_group, factory: :guest_group
  end

  factory :poll_meeting, class: Poll do
    poll_type "meeting"
    title "This is a meeting"
    details "with a description"
    association :author, factory: :user
    poll_option_names ['01-01-2015']
    association :guest_group, factory: :guest_group
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

  factory :public_community, class: Communities::Public
  factory :email_community, class: Communities::Email
  factory :facebook_community, class: Communities::Facebook
  factory :slack_community, class: Communities::Slack

  factory :visitor do
    association :community, factory: :public_community
    name "John Doe"
    email "john@doe.com"
  end

  factory :received_email do
    sender_email "John Doe <john@doe.com>"
    body "FORWARDED MESSAGE------ TO: Mary <mary@example.com>, beth@example.com, Tim <tim@example.com> SUBJECT: We're having an argument! blahblahblah"
  end

end
