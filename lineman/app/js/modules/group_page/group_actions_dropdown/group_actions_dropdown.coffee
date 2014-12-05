angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_options_dropdown.html'
  replace: true
  controller: 'GroupOptionsDropdownController'
  link: (scope, element, attrs) ->
