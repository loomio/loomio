BaseModel = require 'shared/models/base_model.coffee'

module.exports = class TranslationModel extends BaseModel
  @singular: 'translation'
  @plural: 'translations'
  @indices: ['id']
