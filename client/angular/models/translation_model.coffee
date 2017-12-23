BaseModel = require 'shared/models/base_model'

angular.module('loomioApp').factory 'TranslationModel', ->
  class TranslationModel extends BaseModel
    @singular: 'translation'
    @plural: 'translations'
    @indices: ['id']
