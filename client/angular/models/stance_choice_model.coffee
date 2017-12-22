AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'StanceChoiceModel', (BaseModel) ->
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
