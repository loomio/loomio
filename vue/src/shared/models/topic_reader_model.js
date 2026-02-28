import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';

export default class TopicReaderModel extends BaseModel {
  static singular = 'topicReader';
  static plural = 'topicReaders';
  static indices = ['topicId', 'userId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      topicId: null,
      userId: null,
      guest: false
    };
  }

  relationships() {
    this.belongsTo('user', {from: 'users'});
    this.belongsTo('topic');
  }
};
