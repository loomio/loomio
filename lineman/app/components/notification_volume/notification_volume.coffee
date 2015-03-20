angular.module('loomioApp').directive 'notificationVolume', ->
  scope: {translateRoot: '@', volume: '@', model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notification_volume/notification_volume.html'
  replace: true
  controller: 'NotificationVolumeController'
  link: (scope, element, attrs) ->
