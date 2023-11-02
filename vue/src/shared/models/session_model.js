import BaseModel from '@/shared/record_store/base_model';

export default class SessionModel extends BaseModel {
  static singular = 'session';
  static plural = 'sessions';
  static serializableAttributes = ['type', 'code', 'email', 'password', 'rememberMe'];
  static serializationRoot = 'user';
};
