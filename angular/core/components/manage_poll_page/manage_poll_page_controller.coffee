angular.module('loomioApp').controller 'ManagePollPageController', ($scope, $translate, $rootScope, $routeParams, Records, $location, ModalService, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll
      $rootScope.$broadcast 'setTitle', $translate.instant('manage_poll_page.title', title: @poll.title)

  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
