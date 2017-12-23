BaseModel = require 'shared/models/base_model'

angular.module('loomioApp').factory 'RegistrationModel', ->
  class RegistrationModel extends BaseModel
    @singular: 'registration'
    @plural: 'registrations'
    @serializableAttributes: ['name', 'email', 'password', 'passwordConfirmation', 'recaptcha']
    @serializationRoot: 'user'
