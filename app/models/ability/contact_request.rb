module Ability::ContactRequest
  def initialize(user)
    super(user)

    can :create, ::ContactRequest do |request|
      (user.groups & request.recipient.groups).any?
    end
  end
end
