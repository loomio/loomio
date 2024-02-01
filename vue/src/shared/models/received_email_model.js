import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';

export default class ReceivedEmailModel extends BaseModel {
  static singular = 'receivedEmail';
  static plural = 'receivedEmails';
  static indices = ['groupId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      groupId: null
    };
  }
};
