BaseModel = require 'shared/models/base_model'
AppConfig = require 'shared/services/app_config.coffee'

module.exports = class ContactMessageModel extends BaseModel
  @singular: 'contactMessage'
  @plural: 'contactMessages'
  @serializableAttributes: AppConfig.permittedParams.contact_message
