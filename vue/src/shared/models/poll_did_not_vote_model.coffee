import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class PollDidNotVoteModel extends BaseModel
  @singular: 'poll_did_not_vote'
  @plural: 'poll_did_not_votes'
  @indices: ['pollId', 'userId']

  relationships: ->
    @belongsTo 'user'
    @belongsTo 'poll'
