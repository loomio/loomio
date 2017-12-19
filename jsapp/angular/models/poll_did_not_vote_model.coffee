angular.module('loomioApp').factory 'PollDidNotVoteModel', (AppConfig, BaseModel) ->
  class PollDidNotVoteModel extends BaseModel
    @singular: 'poll_did_not_vote'
    @plural: 'poll_did_not_votes'
    @indices: ['pollId', 'userId']
    @serializableAttributes: AppConfig.permittedParams.pollDidNotVote

    relationships: ->
      @belongsTo 'user'
      @belongsTo 'poll'
