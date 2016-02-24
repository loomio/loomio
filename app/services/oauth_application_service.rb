class OauthApplicationService
  def self.create(oauth_application:, actor:)
    actor.ability.authorize! :create, oauth_application
    oauth_application.owner = actor

    return false unless oauth_application.valid?

    oauth_application.save
    EventBus.broadcast('oauth_application_create', oauth_application, actor)
  end

  def self.update(oauth_application:, params:, actor:)
    actor.ability.authorize! :update, oauth_application

    oauth_application.assign_attributes(params.slice(:name, :redirect_uri, :logo, :scopes))
    return false unless oauth_application.valid?
    oauth_application.save

    EventBus.broadcast('oauth_application_update', oauth_application, actor, params)
  end

  def self.destroy(oauth_application:, actor:)
    actor.ability.authorize! :destroy, oauth_application
    oauth_application.destroy

    EventBus.broadcast('oauth_application_destroy', oauth_application, actor)
  end

  def self.revoke_access(oauth_application:, actor:)
    actor.ability.authorize! :revoke_access, oauth_application
    Doorkeeper::AccessToken.revoke_all_for oauth_application.id, actor

    EventBus.broadcast('oauth_application_revoke_access', oauth_application, actor)
  end
end
