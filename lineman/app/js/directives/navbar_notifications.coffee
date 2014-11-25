angular.module('loomioApp').directive 'navbarNotifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/templates/navbar_notifications.html'
  replace: true
  controller: 'NavbarNotificationsController'
  link: (scope, element, attrs) ->
