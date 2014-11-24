angular.module('loomioApp').directive 'groupNotificationsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_notifications_dropdown.html'
  replace: true
  controller: 'GroupNotificationsDropdownController'
  link: (scope, element, attrs) ->
