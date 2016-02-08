angular.module('loomioApp').factory 'TranslationModel', (BaseModel) ->
  class TranslationModel extends BaseModel
    @singular: 'translation'
    @plural: 'translations'
    @indices: ['id']
