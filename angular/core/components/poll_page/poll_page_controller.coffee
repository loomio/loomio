angular.module('loomioApp').controller 'PollPageController', ($scope, $rootScope, $routeParams, Records, $location, ModalService, PollCommonOutcomeForm) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll
      $rootScope.$broadcast 'setTitle', @poll.title

      if $location.search().set_outcome
        ModalService.open PollCommonOutcomeForm, outcome: -> Records.outcomes.build(pollId: poll.id)

  @init Records.polls.find $routeParams.key
  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
