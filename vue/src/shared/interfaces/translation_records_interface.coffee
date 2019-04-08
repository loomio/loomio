import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import TranslationModel     from '@/shared/models/translation_model'

export default class TranslationRecordsInterface extends BaseRecordsInterface
  model: TranslationModel

  fetchTranslation: (translatable, locale) ->
    @fetch
      path: 'inline'
      params:
        model: translatable.constructor.singular
        id: translatable.id
        to: locale
