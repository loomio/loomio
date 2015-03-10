angular.module('loomioApp').directive 'notificationVolume', ->
  scope: {translateRoot: '@', volume: '@', model: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/notification_volume/notification_volume.html'
  replace: true
  controller: 'NotificationVolumeController'
  link: (scope, element, attrs) ->
