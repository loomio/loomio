angular.module('loomioApp').directive 'navbarNotifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_notifications.html'
  replace: true
  controller: 'NavbarNotificationsController'
  link: (scope, element, attrs) ->
