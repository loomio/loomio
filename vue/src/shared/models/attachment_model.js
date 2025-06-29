import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';

export default class AttachmentModel extends BaseModel {
  static singular = 'attachment';
  static plural = 'attachments';
  static indices = ['recordType', 'recordId'];

  model() {
    return Records[BaseModel.eventTypeMap[this.recordType]].find(this.recordId);
  }

  group() {
    return this.model().group();
  }

  relationships() {
    return this.belongsTo('author', {from: 'users'});
  }

  isAnImage() {
    return this.icon === 'image';
  }
};
