BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
RegistrationModel    = require 'shared/models/registration_model.coffee'

module.exports = class RegistrationRecordsInterface extends BaseRecordsInterface
  model: RegistrationModel
