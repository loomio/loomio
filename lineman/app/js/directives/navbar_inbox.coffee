angular.module('loomioApp').directive 'navbarInbox', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/navbar_inbox.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
