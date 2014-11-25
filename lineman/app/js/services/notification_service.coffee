angular.module('loomioApp').factory 'NotificationService', ($http, RestfulService) ->
  new class NotificationService extends RestfulService
    resource_plural: 'notifications'
