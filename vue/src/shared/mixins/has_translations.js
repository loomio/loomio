import Records from '@/shared/services/records';
import { reactive } from 'vue';

export default new class HasTranslations {
  apply(model) {
    model.translate = (locale) => {
      Records.translations.fetchTranslation(model, locale).then(data => reactive(model).translation = data.translations[0].fields);
    }

    reactive(model).translation = {};
  }
}
