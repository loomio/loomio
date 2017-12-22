AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'PollDidNotVoteModel', (BaseModel) ->
  class PollDidNotVoteModel extends BaseModel
    @singular: 'poll_did_not_vote'
    @plural: 'poll_did_not_votes'
    @indices: ['pollId', 'userId']
    @serializableAttributes: AppConfig.permittedParams.pollDidNotVote

    relationships: ->
      @belongsTo 'user'
      @belongsTo 'poll'
