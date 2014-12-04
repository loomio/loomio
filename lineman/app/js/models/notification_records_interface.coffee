angular.module('loomioApp').factory 'NotificationRecordsInterface', (BaseRecordsInterface, NotificationModel) ->
  class NotificationRecordsInterface extends BaseRecordsInterface
    model: NotificationModel
