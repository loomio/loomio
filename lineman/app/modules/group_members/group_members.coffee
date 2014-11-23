angular.module('loomioApp').directive 'group_members', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_members.html'
  replace: true
  controller: 'GroupMembersController'
  link: (scope, element, attrs) ->
