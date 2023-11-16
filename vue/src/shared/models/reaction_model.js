import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default class ReactionModel extends BaseModel {
  static singular = 'reaction';
  static plural = 'reactions';
  static indices = ['userId', 'reactableId', 'reactableType'];
  static lazyLoad = true;

  relationships() {
    this.belongsTo('user');
  }

  model() {
    return this.recordStore[`${this.reactableType.toLowerCase()}s`].find(this.reactableId);
  }
};
