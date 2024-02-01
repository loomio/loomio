import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TranslationModel     from '@/shared/models/translation_model';

export default class TranslationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TranslationModel;
    this.baseConstructor(recordStore); 
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
