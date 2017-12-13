module Ability::Identity
  def initialize(user)
    super(user)

    can [:show, :destroy], ::Identities::Base do |identity|
      user.identities.include? identity
    end
  end
end
