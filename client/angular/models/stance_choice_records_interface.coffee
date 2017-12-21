angular.module('loomioApp').factory 'StanceChoiceRecordsInterface', (BaseRecordsInterface, StanceChoiceModel) ->
  class StanceChoiceRecordsInterface extends BaseRecordsInterface
    model: StanceChoiceModel
