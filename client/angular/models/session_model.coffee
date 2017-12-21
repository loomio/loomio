angular.module('loomioApp').factory 'SessionModel', (BaseModel) ->
  class SessionModel extends BaseModel
    @singular: 'session'
    @plural: 'sessions'
    @serializableAttributes: ['type', 'email', 'password', 'rememberMe']
    @serializationRoot: 'user'
