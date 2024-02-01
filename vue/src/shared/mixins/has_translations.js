export default new class HasTranslations {
  apply(model) {
    model.translate = locale => model.recordStore.translations.fetchTranslation(model, locale).then(data => model.translation = data.translations[0].fields);

    return model.translation = {};
  }
}
