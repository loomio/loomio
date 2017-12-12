module Ability::DiscussionReader
  def initialize(user)
    super(user)

    can [:update], ::DiscussionReader do |reader|
      reader.user.id == user.id
    end
  end
end
