Session       = require 'shared/services/session.coffee'
Records       = require 'shared/services/records.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ subscribeToLiveUpdate } = require 'shared/helpers/user.coffee'
{ myLastStanceFor }       = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').controller 'PollPageController', ($scope, $rootScope, $routeParams) ->
  @init = (poll) =>
    if poll and !@poll?
      @poll = poll

      $rootScope.$broadcast 'currentComponent',
        group: @poll.group()
        title: poll.title
        page: 'pollPage'
        skipScroll: true

      subscribeToLiveUpdate(poll_key: @poll.key)

      if LmoUrlService.params().share
        ModalService.open 'PollCommonShareModal', poll: => @poll

      if LmoUrlService.params().set_outcome
        ModalService.open 'PollCommonOutcomeModal', outcome: => Records.outcomes.build(pollId: @poll.id)

      if LmoUrlService.params().change_vote
        ModalService.open 'PollCommonEditVoteModal', stance: => myLastStanceFor(@poll)

  Records.polls.fetchComplete($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
