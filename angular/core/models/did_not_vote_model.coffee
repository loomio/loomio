angular.module('loomioApp').factory 'DidNotVoteModel', (BaseModel) ->
  class DidNotVoteModel extends BaseModel
    @singular: 'didNotVote'
    @plural: 'didNotVotes'
    @indices: ['id', 'proposalId']

    relationships: ->
      @belongsTo 'user'
      @belongsTo 'proposal'
