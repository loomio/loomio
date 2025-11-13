import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TranslationModel     from '@/shared/models/translation_model';
import { snakeCase, camelCase, upperFirst } from 'lodash-es';

export default class TranslationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TranslationModel;
    this.baseConstructor(recordStore);
  }

  addTo(model, locale) {
    return this.findOrFetchByModel(model, locale).then((translation) => {
      model.translationId = translation.id
    })
  }

  findOrFetchByModel(model, locale) {
    const record = this.findByModel(model, locale);
    if (record) {
      return Promise.resolve(record);
    } else {
      return this.fetchByModel(model, locale).then((data) => {
        return this.findByModel(model, locale);
      });
    }
  }

  findByModel(model, locale) {
    return this.find({
      translatableType: upperFirst(camelCase(model.constructor.singular)),
      translatableId: model.id,
      language: locale
    })[0];
  }

  fetchByModel(model, locale) {
    return this.fetch({
      path: 'inline',
      params: {
        model: snakeCase(model.constructor.singular),
        id: model.id,
        to: locale
      }
    });
  }
};
