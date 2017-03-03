angular.module('loomioApp').controller 'StartPollPageController', ($scope, $window, $rootScope, $routeParams, Records, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build(pollType: $routeParams.poll_type)

  $scope.$on 'pollSaved', (event, pollKey) ->
    $window.location = LmoUrlService.poll(Records.polls.find(pollKey), {share: true})

  @icon = ->
    PollService.iconFor(@poll)

  return
