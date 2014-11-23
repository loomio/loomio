angular.module('loomioApp').directive 'groupSubgroups', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_subgroups.html'
  replace: true
  controller: 'GroupSubgroupsController'
  link: (scope, element, attrs) ->
