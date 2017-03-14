angular.module('loomioApp').controller 'SharePollPageController', ($scope, $translate, $rootScope, $routeParams, Records, $location, ModalService, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll
      $rootScope.$broadcast 'setTitle', $translate.instant('share_poll_page.title', title: @poll.title)

  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
