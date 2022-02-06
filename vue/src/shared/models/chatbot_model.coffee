import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class ChatbotModel extends BaseModel
  @singular: 'chatbot'
  @plural: 'chatbots'

  defaultValues: ->
    groupId: null
    server: null
    username: null
    password: []
    authorId: []

  relationships: ->
    @belongsTo 'group'
