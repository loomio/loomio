BaseRecordsInterface = require 'shared/record_store/base_records_interface'
RegistrationModel    = require 'shared/models/registration_model'

module.exports = class RegistrationRecordsInterface extends BaseRecordsInterface
  model: RegistrationModel
