BaseModel = require 'shared/record_store/base_model'

module.exports = class RegistrationModel extends BaseModel
  @singular: 'registration'
  @plural: 'registrations'
  @serializableAttributes: ['name', 'email', 'password', 'passwordConfirmation', 'recaptcha', 'legalAccepted']
  @serializationRoot: 'user'
