angular.module('loomioApp').factory 'OutcomeRecordsInterface', (BaseRecordsInterface, OutcomeModel) ->
  class OutcomeRecordsInterface extends BaseRecordsInterface
    model: OutcomeModel
