angular.module('loomioApp').factory 'OauthApplicationModel', (BaseModel, AppConfig) ->
  class OauthApplicationModel extends BaseModel
    @singular: 'oauthApplication'
    @plural: 'oauthApplications'
    @serializationRoot: 'oauth_application'
    @serializableAttributes: AppConfig.permittedParams.oauth_application

    defaultValues: ->
      logoUrl: '/img/default-logo-medium.png'

    redirectUriArray: ->
      @redirectUri.split("\n")

    revokeAccess: ->
      @remote.postMember(@id, 'revoke_access')

    uploadLogo: (file) =>
      @remote.upload("#{@id}/upload_logo", file)
