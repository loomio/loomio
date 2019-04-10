BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class OauthApplicationModel extends BaseModel
  @singular: 'oauthApplication'
  @plural: 'oauthApplications'
  @serializationRoot: 'oauth_application'
  @serializableAttributes: AppConfig.permittedParams.oauth_application

  defaultValues: ->
    logoUrl: AppConfig.theme.icon_src

  redirectUriArray: ->
    @redirectUri.split("\n")

  revokeAccess: ->
    @remote.postMember(@id, 'revoke_access')

  uploadLogo: (file) =>
    @remote.upload("#{@id}/upload_logo", file)
