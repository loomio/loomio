angular.module('loomioApp').controller 'PollPageController', ($scope, $rootScope, $routeParams, Records, $location, ModalService, PollCommonOutcomeForm, PollCommonEditVoteModal, Session) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll
      $rootScope.$broadcast 'setTitle', @poll.title

      if $location.search().set_outcome
        ModalService.open PollCommonOutcomeForm, outcome: -> Records.outcomes.build(pollId: poll.id)

      if $location.search().change_vote
        ModalService.open PollCommonEditVoteModal, stance: -> poll.lastStanceByUser(Session.user())

  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
