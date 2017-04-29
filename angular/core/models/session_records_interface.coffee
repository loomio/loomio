angular.module('loomioApp').factory 'SessionRecordsInterface', (BaseRecordsInterface, SessionModel) ->
  class SessionRecordsInterface extends BaseRecordsInterface
    model: SessionModel

    emailStatus: (email) ->
      @fetch
        path: 'email_status'
        params: {email: email}
