angular.module('loomioApp').directive 'members', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/members.html'
  replace: true
  controller: 'MembersController'
  link: (scope, element, attrs) ->
