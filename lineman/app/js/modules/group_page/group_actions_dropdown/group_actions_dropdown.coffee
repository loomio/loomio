angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controller: 'GroupOptionsDropdownController'
  link: (scope, element, attrs) ->
