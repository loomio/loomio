BaseModel = require 'shared/record_store/base_model'

module.exports = class SessionModel extends BaseModel
  @singular: 'session'
  @plural: 'sessions'
  @serializableAttributes: ['type', 'code', 'email', 'password', 'rememberMe']
  @serializationRoot: 'user'
