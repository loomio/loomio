angular.module('loomioApp').directive 'subgroups', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/subgroups.html'
  replace: true
  controller: 'SubgroupsController'
  link: (scope, element, attrs) ->
