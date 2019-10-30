import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class ContactMessageModel extends BaseModel
  @singular: 'contactMessage'
  @plural: 'contactMessages'
  @serializableAttributes: ["email", "subject", "user_id", "message", "name"]
