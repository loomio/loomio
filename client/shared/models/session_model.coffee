BaseModel = require 'shared/models/base_model.coffee'

module.exports = class SessionModel extends BaseModel
  @singular: 'session'
  @plural: 'sessions'
  @serializableAttributes: ['type', 'email', 'password', 'rememberMe']
  @serializationRoot: 'user'
