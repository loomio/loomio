import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default class ContactMessageModel extends BaseModel {
  static singular = 'contactMessage';
  static plural = 'contactMessages';
  static serializableAttributes = ["email", "subject", "user_id", "message", "name"];
}
