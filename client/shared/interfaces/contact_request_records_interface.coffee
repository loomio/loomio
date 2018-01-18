BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
ContactRequestModel  = require 'shared/models/contact_request_model.coffee'

module.exports = class ContactRequestRecordsInterface extends BaseRecordsInterface
  model: ContactRequestModel
