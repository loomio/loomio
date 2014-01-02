# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reply_token do
    token 'abc123'
    user
    association :replyable, factory: :comment
    after(:build) do |reply_token|
      # reply_token.replyable.group.parent.add_member!(reply_token.user) if reply_token.replyable.group.parent
      reply_token.replyable.group.add_member!(reply_token.user)
    end
    after(:create) do |reply_token|
      reply_token.replyable.group.save
    end
  end

  factory :reply_email, class: OpenStruct do
    to 'Rich Bartlett <reply+abc123@mail.loomio.org>'
    # to [{ full: 'reply+abc123@mail.loomio.org', email: 'reply+abc123@mail.loomio.org', token: 'reply+abc123', host: 'mail.loomio.org', name: 'Richard Bartlett' }]
    from 'user@email.com'
    subject 'email subject'
    text "Hello! \nthis is rather splendid don't you think? \n--\n original old text \n and signitute"
    # body "Hello! \nthis is rather splendid don't you think? \n--\n original old text \n and signitute"
  end
end
