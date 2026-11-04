import BaseModel       from '@/shared/record_store/base_model';

export default class PendingEmailModel extends BaseModel {
  static singular = 'pendingEmail';
  static plural = 'pendingEmails';
  static indices = ['groupId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      groupId: null
    };
  }
};
