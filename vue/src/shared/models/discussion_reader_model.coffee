import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'

export default class DiscussionReaderModel extends BaseModel
  @singular: 'discussionReader'
  @plural: 'discussionReaders'
  @indices: ['discussionId', 'userId']

  defaultValues: ->
    discussionId: null
    userId: null

  relationships: ->
    @belongsTo 'user', from: 'users'
    @belongsTo 'discussion'
