Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->
    $scope.$emit 'processing'
    Records.announcements.fetchNotifiedDefault($scope.announcement.eventForNotifiedDefault()).then (notified) ->
      $scope.announcement.notified = notified if _.any(notified)
    .finally ->
      $scope.$emit 'doneProcessing'

    $scope.nuggets = [1,2,3,4].map (index) -> "announcement.form.helptext_#{index}"

    $scope.search = (query) ->
      Records.announcements.fetchNotified(query).then (notified) ->
        # remove this when we can invite other groups
        _.filter notified, (n) ->
          return true  if n.type != 'FormalGroup' # skip if this isn't a group chip
          return false if !$scope.announcement.model().group() # don't show if there's no group
          $scope.announcement.model().group().key == n.id
  ]
