BaseModel    = require 'shared/models/base_model.coffee'

_ = require 'lodash'

module.exports = class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  relationships: ->
    @belongsTo 'poll'
    @hasMany   'stanceChoices'

  stances: ->
    _.chain(@stanceChoices())
     .map((stanceChoice) -> stanceChoice.stance())
     .filter((stance) -> stance.latest)
     .compact()
     .value()

  beforeRemove: ->
    _.each @stances(), (stance) -> stance.remove()
