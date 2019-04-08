import BaseModel from '@/shared/record_store/base_model'

export default class RegistrationModel extends BaseModel
  @singular: 'registration'
  @plural: 'registrations'
  @serializableAttributes: ['name', 'email', 'password', 'passwordConfirmation', 'recaptcha', 'legalAccepted']
  @serializationRoot: 'user'
