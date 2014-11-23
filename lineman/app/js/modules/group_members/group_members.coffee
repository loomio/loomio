angular.module('loomioApp').directive 'groupMembers', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_members.html'
  replace: true
  controller: 'GroupMembersController'
  link: (scope, element, attrs) ->
