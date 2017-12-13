module Ability::Document
  def initialize(user)
    super(user)

    can [:create, :update], ::Document do |document|
      if document.model.presence
        user.can? :update, document.model
      else
        user.email_verified?
      end
    end

    can :destroy, ::Document do |document|
      user_is_admin_of? document.model.group.id
    end
  end
end
