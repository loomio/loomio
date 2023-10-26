/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ReactionModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default ReactionModel = (function() {
  ReactionModel = class ReactionModel extends BaseModel {
    static initClass() {
      this.singular = 'reaction';
      this.plural = 'reactions';
      this.indices = ['userId', 'reactableId', 'reactableType'];
      this.lazyLoad = true;
    }

    relationships() {
      return this.belongsTo('user');
    }

    model() {
      return this.recordStore[`${this.reactableType.toLowerCase()}s`].find(this.reactableId);
    }
  };
  ReactionModel.initClass();
  return ReactionModel;
})();
