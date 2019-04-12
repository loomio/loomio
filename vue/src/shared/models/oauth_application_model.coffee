import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class OauthApplicationModel extends BaseModel
  @singular: 'oauthApplication'
  @plural: 'oauthApplications'
  @serializationRoot: 'oauth_application'

  defaultValues: ->
    logoUrl: AppConfig.theme.icon_src

  redirectUriArray: ->
    @redirectUri.split("\n")

  revokeAccess: ->
    @remote.postMember(@id, 'revoke_access')

  uploadLogo: (file) =>
    @remote.upload("#{@id}/upload_logo", file)
