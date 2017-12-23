BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
TranslationModel     = require 'shared/models/translation_model.coffee'

module.exports = class TranslationRecordsInterface extends BaseRecordsInterface
  model: TranslationModel

  fetchTranslation: (translatable, locale) ->
    @fetch
      path: 'inline'
      params:
        model: translatable.constructor.singular
        id: translatable.id
        to: locale
