module Ability::DiscussionReader
  def initialize(user)
    super(user)

    can [:update], ::DiscussionReader do |discussion_reader|
      discussion_reader.user.id == user.id
    end

    can [:redeem], ::DiscussionReader do |discussion_reader|
      DiscussionReader.redeemable.exists?(discussion_reader.id)
    end

    can [:make_admin, :remove_admin, :resend, :remove], ::DiscussionReader do |discussion_reader|
      discussion_reader.discussion.admins.exists?(user.id)
    end
  end
end
