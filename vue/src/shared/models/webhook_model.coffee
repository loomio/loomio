import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class WebhookModel extends BaseModel
  @singular: 'webhook'
  @plural: 'webhooks'

  defaultValues: ->
    name: null
    url: null
    format: 'markdown'
    eventKinds: []
    permissions: []
    includeBody: false
    errors: {}

  relationships: ->
    @belongsTo 'group'
