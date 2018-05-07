BaseRecordsInterface = require 'shared/record_store/base_records_interface'
TranslationModel     = require 'shared/models/translation_model'

module.exports = class TranslationRecordsInterface extends BaseRecordsInterface
  model: TranslationModel

  fetchTranslation: (translatable, locale) ->
    @fetch
      path: 'inline'
      params:
        model: translatable.constructor.singular
        id: translatable.id
        to: locale
