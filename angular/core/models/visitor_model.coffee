angular.module('loomioApp').factory 'VisitorModel', (AppConfig, BaseModel) ->
  class VisitorModel extends BaseModel
    @singular: 'visitor'
    @plural: 'visitors'
    @serializableAttributes: AppConfig.permittedParams.visitor
