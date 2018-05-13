Session       = require 'shared/services/session'
Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
ModalService  = require 'shared/services/modal_service'
LmoUrlService = require 'shared/services/lmo_url_service'

{ subscribeTo }     = require 'shared/helpers/cable'
{ myLastStanceFor } = require 'shared/helpers/poll'

$controller = ($rootScope, $routeParams) ->
  @init = (poll) =>
    if poll and !@poll?
      @poll = poll

      EventBus.broadcast $rootScope, 'currentComponent',
        group: poll.group()
        poll:  poll
        title: poll.title
        page: 'pollPage'
        skipScroll: true

      subscribeTo(@poll)

      if LmoUrlService.params().set_outcome
        ModalService.open 'PollCommonOutcomeModal', outcome: => Records.outcomes.build(pollId: @poll.id)

      if LmoUrlService.params().change_vote
        ModalService.open 'PollCommonEditVoteModal', stance: => myLastStanceFor(@poll)

  Records.polls.findOrFetchById($routeParams.key, {}, true).then @init, (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  return

$controller.$inject = ['$rootScope', '$routeParams']
angular.module('loomioApp').controller 'PollPageController', $controller
