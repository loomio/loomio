angular.module('loomioApp').directive 'inbox', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/js/modules/inbox/inbox.html'
  replace: true
  controller: 'InboxController'
  link: (scope, element, attrs) ->
