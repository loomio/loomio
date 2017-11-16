angular.module('loomioApp').directive 'announcementForm', (Records) ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ($scope) ->
    $scope.search = (query) ->
      Records.announcements.fetchNotified(query)
