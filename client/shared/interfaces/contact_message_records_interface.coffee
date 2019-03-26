BaseRecordsInterface = require 'shared/record_store/base_records_interface'
ContactMessageModel  = require 'shared/models/contact_message_model'

module.exports = class ContactMessageRecordsInterface extends BaseRecordsInterface
  model: ContactMessageModel
