BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
ContactMessageModel  = require 'shared/models/contact_message_model.coffee'

module.exports = class ContactMessageRecordsInterface extends BaseRecordsInterface
  model: ContactMessageModel
