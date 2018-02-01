Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->
    if $scope.announcement.kind
      $scope.$emit 'processing'
      Records.announcements.fetchNotifiedDefault($scope.announcement).then (notified) ->
        $scope.announcement.notified = notified
      .finally ->
        $scope.$emit 'doneProcessing'

    $scope.nuggets = [1,2,3,4].map (index) -> "announcement.form.helptext_#{index}"

    $scope.search = (query) ->
      Records.announcements.fetchNotified(query)
  ]
