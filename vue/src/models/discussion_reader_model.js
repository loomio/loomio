import BaseModel       from '@/record_store/base_model';
import AppConfig       from '@/services/app_config';

export default class DiscussionReaderModel extends BaseModel {
  static singular = 'discussionReader';
  static plural = 'discussionReaders';
  static indices = ['discussionId', 'userId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      discussionId: null,
      userId: null
    };
  }

  relationships() {
    this.belongsTo('user', {from: 'users'});
    return this.belongsTo('discussion');
  }
};
