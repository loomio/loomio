import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class ChatbotModel extends BaseModel
  @singular: 'chatbot'
  @plural: 'chatbots'

  defaultValues: ->
    groupId: null
    name: null
    server: null
    accessToken: null
    eventKinds: 'new_discussion discussion_edited poll_created poll_edited poll_closing_soon poll_expired poll_reopened outcome_created'.split(' ')
    kind: 'matrix'
    errors: {}

  relationships: ->
    @belongsTo 'group'
