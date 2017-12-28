BaseModel = require 'shared/record_store/base_model.coffee'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class ContactMessageModel extends BaseModel
  @singular: 'contactMessage'
  @plural: 'contactMessages'
  @serializableAttributes: AppConfig.permittedParams.contact_message
