FactoryBot.define do

  factory :blacklisted_password do
    string { "MyString" }
  end

  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:formal_group)}
  end

  factory :pending_membership, class: Membership do |m|
    m.user { |u| u.association(:unverified_user)}
    m.group { |g| g.association(:formal_group)}
  end

  factory :tag, class: Tag do
    association :group, factory: :formal_group
    # name "metatag"
    # color "#656565"
  end

  factory :discussion_tag do
    discussion
    tag
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    legal_accepted { true }
    password { 'complex_password' }
    time_zone { "Pacific/Tarawa" }
    email_verified { true }

    after(:build) do |user|
      user.generate_username
    end
  end

  factory :unverified_user, class: User do
    sequence(:email) { Faker::Internet.email }
    email_verified { false }
  end

  factory :login_token do
    user
  end

  factory :admin_user, class: User do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password { 'complex_password' }
    is_admin {true}
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :slack_identity, class: Identities::Slack do
    user
    identity_type { "slack" }
    access_token { "dat_access" }
    uid { "U123" }
    sequence(:name) { Faker::Name.name }
    sequence(:email) { Faker::Internet.email }
    custom_fields {{
      slack_team_id: "T123",
      slack_team_name: "Hojo's Honchos"
    }}
  end

  factory :facebook_identity, class: Identities::Facebook do
    user
    identity_type { "facebook" }
    access_token { "access_dat" }
    uid { "U123" }
    sequence(:name) { Faker::Name.name }
    sequence(:email) { Faker::Internet.email }
    custom_fields { { facebook_group_id: "G123" } }
  end

  factory :microsoft_identity, class: Identities::Microsoft do
    user
    identity_type { "microsoft" }
    access_token { "https://outlook.office.com/webhook.url" }
    uid { "https://outlook.office.com/webhook.url" }
  end

  factory :contact do
    user
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    source { 'gmail' }
  end

  factory :formal_group do
    sequence(:name) { Faker::Name.name }
    description { 'A description for this group' }
    handle { GroupService.suggest_handle(name: name, parent_handle: parent&.handle) }
    group_privacy { 'open' }
    discussion_privacy_options { 'public_or_private' }
    members_can_add_members { true }
    after(:create) do |group|
      user = create(:user)
      group.parent&.add_admin!(user)
      group.add_admin!(user)
    end
  end

  factory :group_identity do
    association :group, factory: :formal_group
    association :identity, factory: :slack_identity
  end

  factory :event do
    discussion
    association :eventable, factory: :comment
    user
    sequence_id { 1 }
    kind { :new_comment }
  end

  factory :version, class: PaperTrail::Version do
    association :item, factory: :discussion
    event { :updated }
    object_changes { {} }
  end

  factory :discussion_event, class: Event do
    association :eventable, factory: :discussion
    user
    kind { :new_discussion }
  end

  factory :discussion do
    association :author, :factory => :user
    association :group, :factory => :formal_group
    title { Faker::Name.name }
    description { 'A description for this discussion. Should this be *rich*?' }
    uses_markdown { true }
    private { true }
    after(:build) do |discussion|
      discussion.group.parent&.add_member!(discussion.author)
      discussion.group.add_member!(discussion.author)
    end
    after(:create) do |discussion|
      discussion.group.save
    end
  end

  factory :discussion_reader do
    discussion
    user
  end

  factory :comment do
    user
    discussion
    body { 'body of the comment' }

    after(:build) do |comment|
      comment.discussion.group.parent.add_member!(comment.user) if comment.discussion.group.parent
      comment.discussion.group.add_member!(comment.user)
    end
    after(:create) do |comment|
      comment.discussion.group.save
    end
  end

  factory :reaction do
    association :reactable, factory: :comment
    user
    reaction { "+1" }
  end

  factory :invitation do
    recipient_email { Faker::Internet.email }
    single_use { true }
    intent {'join_group'}
    association :inviter, factory: :user
    association :group, factory: :formal_group
  end

  factory :membership_request do
    introduction { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    name { Faker::Name.name }
    association :group,     factory: :formal_group
    association :requestor, factory: :user
  end

  factory :attachment do
    user
    filename { Faker::Name.name }
    location { Faker::Company.logo }
  end

  factory :document do
    association :author, factory: :user
    association :model, factory: :discussion
    title { Faker::Name.name }
    url { Faker::Internet.url }
  end

  factory :translation do
    language { 'en' }
    fields {{ body: 'Successful translation' }}
  end

  factory :search_result do
    discussion
    motion
    comment
    discussion_blurb { "discussion blurb" }
    motion_blurb { "motion blurb" }
    comment_blurb { "comment blurb" }
    priority { 1.0 }
    query { "test query" }
  end

  factory :webhook do
    association :hookable, factory: :discussion
    uri { "www.test.com" }
    kind { :slack }
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

  factory :poll_option do
    name { "Plan A" }
  end

  factory :poll do
    poll_type { "poll" }
    title { "This is a poll" }
    details { "with a description" }
    association :author, factory: :user
    poll_option_names { ["engage"] }
  end

  factory :poll_proposal, class: Poll do
    poll_type { "proposal" }
    title { "This is a proposal" }
    details { "with a description" }
    association :author, factory: :user
    poll_option_names { %w[agree abstain disagree block] }
  end

  factory :poll_dot_vote, class: Poll do
    poll_type { "dot_vote" }
    title { "This is a dot vote" }
    details { "with a description" }
    association :author, factory: :user
    poll_option_names { %w(apple banana orange) }
    custom_fields { { dots_per_person: 8 } }
  end

  factory :poll_meeting, class: Poll do
    poll_type { "meeting" }
    title { "This is a meeting" }
    details { "with a description" }
    association :author, factory: :user
    poll_option_names { ['01-01-2015'] }
    custom_fields { { can_respond_maybe: false } }
  end

  factory :poll_ranked_choice, class: Poll do
    poll_type { "ranked_choice" }
    title { "This is a ranked choice" }
    details { "with a description" }
    association :author, factory: :user
    poll_option_names { %w(apple banana orange) }
    custom_fields { { minimum_stance_choices: 2 } }
  end

  factory :outcome do
    poll
    association :author, factory: :user
    statement { "An outcome" }
  end

  factory :stance do
    poll
    association :participant, factory: :user
  end

  factory :stance_choice do
    poll_option
  end

  factory :notification do
    user
    event
    url { "https://www.example.com" }
    association :actor, factory: :user
  end

  factory :received_email do
    sender_email { "John Doe <john@doe.com>" }
    body { "FORWARDED MESSAGE------ TO: Mary <mary@example.com>, beth@example.com, Tim <tim@example.com> SUBJECT: We're having an argument! blahblahblah" }
  end

end
