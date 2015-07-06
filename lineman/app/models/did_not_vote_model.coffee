angular.module('loomioApp').factory 'DidNotVoteModel', (BaseModel) ->
  class DidNotVoteModel extends BaseModel
    @singular: 'didNotVote'
    @plural: 'didNotVotes'
    @indices: ['id', 'proposalId']

    user: ->
      @recordStore.users.find(@userId)

    proposal: ->
      @recordStore.proposals.find(@proposalId)
