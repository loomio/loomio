angular.module('loomioApp').controller 'PollPageController', ($scope, $rootScope, $routeParams, CommunityService, Records, $location, ModalService, PollService, PollCommonOutcomeForm, PollCommonEditVoteModal, AddCommunityModal, PollCommonShareModal, Session) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollPage', skipScroll: true })

  @init = (poll) =>
    if poll and !@poll?
      @poll = poll
      $rootScope.$broadcast 'setTitle', @poll.title

      if $location.search().add_community
        ModalService.open AddCommunityModal, community: =>
          CommunityService.buildCommunity(@poll, $location.search().add_community)

      if $location.search().share
        ModalService.open PollCommonShareModal, poll: => @poll

      if $location.search().set_outcome
        ModalService.open PollCommonOutcomeForm, outcome: => Records.outcomes.build(pollId: @poll.id)

      if $location.search().change_vote
        ModalService.open PollCommonEditVoteModal, stance: => PollService.lastStanceBy(Session.participant(), @poll)

  Records.polls.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
