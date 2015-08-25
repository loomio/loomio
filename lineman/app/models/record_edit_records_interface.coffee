angular.module('loomioApp').factory 'RecordEditRecordsInterface', (BaseRecordsInterface, RecordEditModel) ->
  class RecordEditRecordsInterface extends BaseRecordsInterface
    model: RecordEditModel