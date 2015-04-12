angular.module('loomioApp').factory 'NotificationRecordsInterface', (BaseRecordsInterface, NotificationModel) ->
  class NotificationRecordsInterface extends BaseRecordsInterface
    model: NotificationModel

    viewed: ->
      any = false
      _.each @collection.find({viewed: false}), (n) =>
        any = true
        n.viewed = true
        @collection.update(n)

      @restfulClient.post 'viewed' if any
