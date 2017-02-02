angular.module('loomioApp').controller 'PollPageController', ($scope, $rootScope, $routeParams, Records) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll

      $rootScope.$broadcast 'setTitle', @poll.title

  @init Records.polls.find $routeParams.key
  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
