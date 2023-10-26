/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TranslationRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TranslationModel     from '@/shared/models/translation_model';

export default TranslationRecordsInterface = (function() {
  TranslationRecordsInterface = class TranslationRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = TranslationModel;
    }

    fetchTranslation(translatable, locale) {
      return this.fetch({
        path: 'inline',
        params: {
          model: translatable.constructor.singular,
          id: translatable.id,
          to: locale
        }
      });
    }
  };
  TranslationRecordsInterface.initClass();
  return TranslationRecordsInterface;
})();
