BaseModel = require 'shared/models/base_model'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class StanceChoiceModel extends BaseModel
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
