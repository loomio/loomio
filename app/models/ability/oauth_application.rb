module Ability::OauthApplication
  def initialize(user)
    super(user)

    can [:show, :update, :destroy], ::OauthApplication do |application|
      application.owner_id == user.id
    end

    can :revoke_access, ::OauthApplication do |application|
      ::OauthApplication.authorized_for(user).include? application
    end

    can :create, ::OauthApplication do |application|
      user.email_verified?
    end
  end
end
