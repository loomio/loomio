angular.module('loomioApp').directive 'threadNotificationLevelDropdown', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/thread_notification_level_dropdown/thread_notification_level_dropdown.html'
  replace: true
  controller: 'ThreadNotificationLevelController'
  link: (scope, element, attrs) ->
