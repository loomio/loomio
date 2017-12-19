angular.module('loomioApp').factory 'ReactionModel', (BaseModel, AppConfig) ->
  class ReactionModel extends BaseModel
    @singular: 'reaction'
    @plural: 'reactions'
    @indices: ['userId', 'reactableId']
    @serializableAttributes: AppConfig.permittedParams.reaction

    relationships: ->
      @belongsTo 'user'

    model: ->
      @recordStore["#{@reactableType.toLowerCase()}s"].find(@reactableId)
