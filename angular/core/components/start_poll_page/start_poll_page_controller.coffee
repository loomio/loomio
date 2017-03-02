angular.module('loomioApp').controller 'StartPollPageController', ($scope, $rootScope, $routeParams, Records, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build(pollType: $routeParams.poll_type)

  @icon = ->
    PollService.iconFor(@poll)

  return
