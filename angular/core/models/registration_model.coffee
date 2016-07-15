angular.module('loomioApp').factory 'RegistrationModel', (BaseModel) ->
  class RegistrationModel extends BaseModel
    @singular: 'registration'
    @plural: 'registrations'
    @serializableAttributes: ['email', 'password', 'passwordConfirmation']
    @serializationRoot: 'user'
