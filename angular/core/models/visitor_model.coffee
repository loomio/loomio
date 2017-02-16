angular.module('loomioApp').factory 'VisitorModel', (BaseModel) ->
  class VisitorModel extends BaseModel
    @singular: 'visitor'
    @plural: 'visitors'
