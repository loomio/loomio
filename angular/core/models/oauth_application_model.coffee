angular.module('loomioApp').factory 'OauthApplicationModel', (BaseModel) ->
  class OauthApplicationModel extends BaseModel
    @singular: 'oauthApplication'
    @plural: 'oauthApplications'
