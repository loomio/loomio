import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class WebhookModel extends BaseModel
  @singular: 'webhook'
  @plural: 'webhooks'
  
  @validEventKinds = [
    'new_discussion',
    'new_comment',
    'poll_created',
    'poll_closing_soon',
    'poll_expired',
    'stance_created'
  ]

  defaultValues: ->
    name: null
    url: null
    eventKinds: @constructor.validEventKinds

  relationships: ->
    @belongsTo 'group'
