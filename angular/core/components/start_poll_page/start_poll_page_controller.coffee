angular.module('loomioApp').controller 'StartPollPageController', ($scope, $location, $rootScope, $routeParams, Records, LoadingService, PollService, ModalService, AnnouncementModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build
    title:       $location.search().title
    pollType:    $routeParams.poll_type
    groupId:     $location.search().group_id
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  @icon = ->
    PollService.iconFor(@poll)

  LoadingService.listenForLoading $scope
  PollService.applyPollStartSequence @,
    emitter: $scope
    afterSaveComplete: (poll) ->
      ModalService.open AnnouncementModal, announcement: ->
        Records.announcements.buildFromModel(poll)

  return
