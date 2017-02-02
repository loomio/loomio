angular.module('loomioApp').factory 'StanceChoiceModel', (BaseModel, AppConfig) ->
  class StanceChoiceModel extends BaseModel
    @singular: 'stanceChoice'
    @plural: 'stanceChoices'
    @indices: ['pollOptionId', 'stanceId']
    @serializableAttributes: AppConfig.permittedParams.stanceChoices

    defaultValues: ->
      score: 1

    relationships: ->
      @belongsTo 'pollOption'
      @belongsTo 'stance'

    poll: ->
      @stance().poll() if @stance()
