/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let HasTranslations;
export default new (HasTranslations = class HasTranslations {
  apply(model) {
    model.translate = locale => model.recordStore.translations.fetchTranslation(model, locale).then(data => model.translation = data.translations[0].fields);

    return model.translation = {};
  }
});
