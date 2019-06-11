import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class AttachmentModel extends BaseModel
  @singular: 'attachment'
  @plural: 'attachments'
  @indices: ['groupId', 'recordType', 'recordId']

  relationships: ->
    @belongsTo 'group'
    @belongsTo 'author', from: 'users'

  isAnImage: ->
    @icon == 'image'
