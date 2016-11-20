angular.module('loomioApp').factory 'RegistrationModel', (BaseModel) ->
  class RegistrationModel extends BaseModel
    @singular: 'registration'
    @plural: 'registrations'
    @serializableAttributes: ['name', 'email', 'password', 'passwordConfirmation', 'honeypot']
    @serializationRoot: 'user'
