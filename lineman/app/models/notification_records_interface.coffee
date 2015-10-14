angular.module('loomioApp').factory 'NotificationRecordsInterface', (BaseRecordsInterface, NotificationModel) ->
  class NotificationRecordsInterface extends BaseRecordsInterface
    model: NotificationModel

    fetchMyNotifications: ->
      @fetch
        params:
          from: 0
          per: 25
        cacheKey: "myNotifications"

    viewed: ->
      any = false
      _.each @collection.find(viewed: { $ne: true}), (n) =>
        any = true
        n.update(viewed: true)

      @remote.post 'viewed' if any
