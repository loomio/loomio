import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';

export default class DiscussionReaderModel extends BaseModel {
  static singular = 'discussionReader';
  static plural = 'discussionReaders';
  static indices = ['discussionId', 'userId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      discussionId: null,
      userId: null,
      guest: false
    };
  }

  relationships() {
    this.belongsTo('user', {from: 'users'});
    this.belongsTo('discussion');
  }
};
