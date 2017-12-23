BaseModel = require 'shared/models/base_model'

angular.module('loomioApp').factory 'SessionModel', ->
  class SessionModel extends BaseModel
    @singular: 'session'
    @plural: 'sessions'
    @serializableAttributes: ['type', 'email', 'password', 'rememberMe']
    @serializationRoot: 'user'
