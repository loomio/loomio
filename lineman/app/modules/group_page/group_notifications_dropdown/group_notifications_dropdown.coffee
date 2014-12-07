angular.module('loomioApp').directive 'groupNotificationsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/group_page/group_notifications_dropdown/group_notifications_dropdown.html'
  replace: true
  controller: 'GroupNotificationsDropdownController'
  link: (scope, element, attrs) ->
