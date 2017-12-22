AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'ReactionModel', (BaseModel) ->
  class ReactionModel extends BaseModel
    @singular: 'reaction'
    @plural: 'reactions'
    @indices: ['userId', 'reactableId']
    @serializableAttributes: AppConfig.permittedParams.reaction

    relationships: ->
      @belongsTo 'user'

    model: ->
      @recordStore["#{@reactableType.toLowerCase()}s"].find(@reactableId)
