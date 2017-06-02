angular.module('loomioApp').controller 'StartPollPageController', ($scope, $location, $rootScope, $routeParams, Records, PollService, ModalService, PollCommonShareModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build
    title:       $location.search().title
    pollType:    $routeParams.poll_type
    communityId: $location.search().community_id
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  @icon = ->
    PollService.iconFor(@poll)

  $scope.$on 'saveComplete', (event, poll) ->
    ModalService.open PollCommonShareModal, poll: -> poll

  return
