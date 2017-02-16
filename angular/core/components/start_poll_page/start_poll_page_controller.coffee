angular.module('loomioApp').controller 'StartPollPageController', ($rootScope, $routeParams, Records) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build(pollType: $routeParams.poll_type)

  return
