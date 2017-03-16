angular.module('loomioApp').controller 'StartPollPageController', ($scope, $location, $rootScope, $routeParams, Records, LmoUrlService, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build(pollType: $routeParams.poll_type)

  $scope.$on 'pollSaved', (event, pollKey) ->
    $location.path(LmoUrlService.poll(Records.polls.find(pollKey))).search(share: true)

  @icon = ->
    PollService.iconFor(@poll)

  return
