import BaseModel from '@/shared/record_store/base_model';

export default class RegistrationModel extends BaseModel {
  static singular = 'registration';
  static plural = 'registrations';
  static serializableAttributes = ['name', 'email', 'password', 'passwordConfirmation', 'legalAccepted', 'emailNewsletter'];
  static serializationRoot = 'user';
};
