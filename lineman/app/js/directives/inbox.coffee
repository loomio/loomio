angular.module('loomioApp').directive 'inbox', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/templates/inbox.html'
  replace: true
  controller: 'InboxController'
  link: (scope, element, attrs) ->
