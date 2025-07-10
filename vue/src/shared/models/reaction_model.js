import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';

export default class ReactionModel extends BaseModel {
  static singular = 'reaction';
  static plural = 'reactions';
  static indices = ['userId', 'reactableId', 'reactableType'];

  relationships() {
    this.belongsTo('user');
  }

  model() {
    return Records[`${this.reactableType.toLowerCase()}s`].find(this.reactableId);
  }
};
