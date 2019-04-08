import BaseModel from '@/shared/record_store/base_model'

export default class TranslationModel extends BaseModel
  @singular: 'translation'
  @plural: 'translations'
  @indices: ['id']
