BaseModel = require 'shared/record_store/base_model'

module.exports = class TranslationModel extends BaseModel
  @singular: 'translation'
  @plural: 'translations'
  @indices: ['id']
