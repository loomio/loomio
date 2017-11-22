angular.module('loomioApp').controller 'StartDiscussionPageController', ($scope, $location, $rootScope, $routeParams, Records, LoadingService, PollService, ModalService, AnnouncementModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startDiscussionPage', skipScroll: true })
  @discussion = Records.discussions.build
    title:       $location.search().title
    groupId:     $location.search().group_id

  LoadingService.listenForLoading $scope

  $scope.$on 'nextStep', (_, discussion) ->
    ModalService.open AnnouncementModal, announcement: ->
      Records.announcements.build
        announceableId:   discussion.id
        announceableType: 'Discussion'

  return
