angular.module('loomioApp').factory 'VisitorRecordsInterface', (BaseRecordsInterface, VisitorModel) ->
  class VisitorRecordsInterface extends BaseRecordsInterface
    model: VisitorModel
