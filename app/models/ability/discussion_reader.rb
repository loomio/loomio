module Ability::DiscussionReader
  def initialize(user)
    super(user)

    can [:update], ::TopicReader do |topic_reader|
      topic_reader.user.id == user.id
    end

    can [:redeem], ::TopicReader do |topic_reader|
      TopicReader.redeemable.exists?(topic_reader.id)
    end

    can [:make_admin, :remove_admin, :resend], ::TopicReader do |topic_reader|
      topic_reader.topic&.admins&.exists?(user.id)
    end

    can [:remove], ::TopicReader do |topic_reader|
      topic_reader.guest && topic_reader.topic&.admins&.exists?(user.id)
    end
  end
end
