BaseModel = require 'shared/record_store/base_model.coffee'

module.exports = class TranslationModel extends BaseModel
  @singular: 'translation'
  @plural: 'translations'
  @indices: ['id']
