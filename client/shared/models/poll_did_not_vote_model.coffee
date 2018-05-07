BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class PollDidNotVoteModel extends BaseModel
  @singular: 'poll_did_not_vote'
  @plural: 'poll_did_not_votes'
  @indices: ['pollId', 'userId']
  @serializableAttributes: AppConfig.permittedParams.pollDidNotVote

  relationships: ->
    @belongsTo 'user'
    @belongsTo 'poll'
