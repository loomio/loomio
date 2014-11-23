angular.module('loomioApp').directive 'group_subgroups', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_subgroups.html'
  replace: true
  controller: 'GroupSubgroupsController'
  link: (scope, element, attrs) ->
