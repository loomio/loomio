angular.module('loomioApp').factory 'CommunityModel', (BaseModel, AppConfig) ->
  class CommunityModel extends BaseModel
    @singular: 'community'
    @plural: 'communities'
    @serializableAttributes: AppConfig.permittedParams.community

    defaultValues: ->
      customFields: {}

    relationships: ->
      @belongsTo 'poll'
      @belongsTo 'user'
