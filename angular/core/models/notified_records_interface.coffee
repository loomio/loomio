angular.module('loomioApp').factory 'NotifiedRecordsInterface', (BaseRecordsInterface) ->
  class NotifiedRecordsInterface extends BaseRecordsInterface
    model:
      singular: 'notified'
      plural:   'notified'

    fetchByFragment: (fragment) ->
      @fetch
        params:
          q: fragment
          per: 5

    fetchByPoll: (pollKey) ->
      @fetch
        path: 'poll'
        params:
          poll_key: pollKey
          per: 1000
