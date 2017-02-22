angular.module('loomioApp').factory 'PollOptionRecordsInterface', (BaseRecordsInterface, PollOptionModel) ->
  class PollOptionRecordsInterface extends BaseRecordsInterface
    model: PollOptionModel
