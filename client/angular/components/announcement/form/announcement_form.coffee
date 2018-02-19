Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

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

    $scope.inviteToDiscussion = ->
      ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel($scope.relevantDiscussion())

    $scope.relevantDiscussion = ->
      return if $scope.announcement.modelName() == 'discussion'
      $scope.announcement.model().discussion()

    $scope.search = (query) ->
      Records.announcements.fetchNotified(query).then (notified) ->
        # remove this when we can invite other groups
        _.filter notified, (n) ->
          return true  if n.type != 'FormalGroup' # skip if this isn't a group chip
          return false if !$scope.announcement.model().group() # don't show if there's no group
          $scope.announcement.model().group().key == n.id
  ]
