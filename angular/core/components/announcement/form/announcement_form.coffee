angular.module('loomioApp').directive 'announcementForm', (Records) ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ($scope) ->
    if $scope.announcement.kind
      $scope.$emit 'processing'
      Records.announcements.fetchNotifiedDefault($scope.announcement.model(), $scope.announcement.kind).then (notified) ->
        $scope.announcement.notified = notified
      .finally ->
        $scope.$emit 'doneProcessing'

    $scope.search = (query) ->
      Records.announcements.fetchNotified(query)
