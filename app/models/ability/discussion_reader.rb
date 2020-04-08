module Ability::DiscussionReader
  def initialize(user)
    super(user)

    can [:update], ::DiscussionReader do |reader|
      reader.user.id == user.id
    end

    can [:redeem], ::DiscussionReader do |reader|
      DiscussionReader.redeemable.exists?(reader.id)
    end
  end
end
