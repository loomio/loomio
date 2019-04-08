BaseModel = require '@/shared/record_store/base_model'
AppConfig = require '@/shared/services/app_config'

export default class ContactMessageModel extends BaseModel
  @singular: 'contactMessage'
  @plural: 'contactMessages'
