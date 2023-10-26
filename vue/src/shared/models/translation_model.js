/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TranslationModel;
import BaseModel from '@/shared/record_store/base_model';

export default TranslationModel = (function() {
  TranslationModel = class TranslationModel extends BaseModel {
    static initClass() {
      this.singular = 'translation';
      this.plural = 'translations';
      this.indices = ['id'];
    }
  };
  TranslationModel.initClass();
  return TranslationModel;
})();
