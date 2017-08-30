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
