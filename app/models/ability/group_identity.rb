module Ability::GroupIdentity
  def initialize(user)
    super(user)

    can [:create], ::GroupIdentity do |group_identity|
      user_is_admin_of?(group_identity.group_id) &&
      user.identities.include?(group_identity.identity)
    end

    can [:destroy], ::GroupIdentity do |group_identity|
      user_is_admin_of?(group_identity.group_id)
    end
  end
end
