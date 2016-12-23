angular.module('loomioApp').factory 'PollOptionModel', (BaseModel) ->
  class PollOptionModel extends BaseModel
    @singular: 'pollOption'
    @plural: 'pollOptions'
    @indices: ['pollId']

    relationships: ->
      @belongsTo 'poll'
