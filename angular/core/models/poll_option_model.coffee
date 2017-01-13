angular.module('loomioApp').factory 'PollOptionModel', (BaseModel) ->
  class PollOptionModel extends BaseModel
    @singular: 'pollOption'
    @plural: 'pollOptions'
    @indices: ['pollId']

    relationships: ->
      @belongsTo 'poll'
      @hasMany   'stanceChoices'

    stances: ->
      _.compact _.map(@stanceChoices(), (stanceChoice) -> stanceChoice.stance())

    beforeRemove: ->
      _.each @stances(), (stance) -> stance.remove()
