angular.module('loomioApp').factory 'OauthApplicationModel', (BaseModel, AppConfig) ->
  class OauthApplicationModel extends BaseModel
    @singular: 'oauthApplication'
    @plural: 'oauthApplications'
    @serializationRoot: 'oauth_application'
    @serializableAttributes: AppConfig.permittedParams.oauth_application

    defaultValues: ->
      logoUrl: AppConfig.theme.default_group_logo_src

    redirectUriArray: ->
      @redirectUri.split("\n")

    revokeAccess: ->
      @remote.postMember(@id, 'revoke_access')

    uploadLogo: (file) =>
      @remote.upload("#{@id}/upload_logo", file)
