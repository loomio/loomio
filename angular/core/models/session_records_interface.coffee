angular.module('loomioApp').factory 'SessionRecordsInterface', (BaseRecordsInterface, SessionModel) ->
  class SessionRecordsInterface extends BaseRecordsInterface
    model: SessionModel
