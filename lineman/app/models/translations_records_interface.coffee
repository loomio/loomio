angular.module('loomioApp').factory 'TranslationRecordsInterface', (BaseRecordsInterface, TranslationModel) ->
  class TranslationRecordsInterface extends BaseRecordsInterface
    model: TranslationModel

    fetchTranslation: (translatable, language) ->
      @fetch
        path: 'inline'
        params:
          model: translatable.constructor.singular
          id: translatable.id
          to: language
