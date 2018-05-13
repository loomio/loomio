BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class ContactMessageModel extends BaseModel
  @singular: 'contactMessage'
  @plural: 'contactMessages'
  @serializableAttributes: AppConfig.permittedParams.contact_message
