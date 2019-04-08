import BaseModel from '@/shared/record_store/base_model'

export default class SessionModel extends BaseModel
  @singular: 'session'
  @plural: 'sessions'
  @serializableAttributes: ['type', 'code', 'email', 'password', 'rememberMe']
  @serializationRoot: 'user'
