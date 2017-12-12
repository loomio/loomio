module Ability::Draft
  def initialize(user)
    super(user)

    can :update, ::Draft do |draft|
      draft.user_id == user.id &&
      can?(:make_draft, draft.draftable)
    end
  end
end
