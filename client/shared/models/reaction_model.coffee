BaseModel = require 'shared/models/base_model'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class ReactionModel extends BaseModel
  @singular: 'reaction'
  @plural: 'reactions'
  @indices: ['userId', 'reactableId']
  @serializableAttributes: AppConfig.permittedParams.reaction

  relationships: ->
    @belongsTo 'user'

  model: ->
    @recordStore["#{@reactableType.toLowerCase()}s"].find(@reactableId)
