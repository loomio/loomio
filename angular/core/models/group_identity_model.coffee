angular.module('loomioApp').factory 'GroupIdentityModel', (AppConfig, BaseModel) ->
  class GroupIdentityModel extends BaseModel
    @singular: 'groupIdentity'
    @plural: 'groupIdentities'
    @serializableAttributes: AppConfig.permittedParams.groupIdentity

    defaultValues: ->
      customFields: {}

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'identity'
