angular.module('loomioApp').controller 'PollsPageController', ($scope, $q, $rootScope, Records, AbilityService, TranslationService, LoadingService, ModalService, PollCommonStartModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollsPage'})

  @pollIds = []

  @loadMore = =>
    Records.polls.search().then (response) =>
      from += per
      _.merge @pollIds, _.pluck(response.polls, 'id')
  LoadingService.applyLoadingFunction @, 'loadMore'
  @loadMore().then(null, (error) -> $rootScope.$broadcast('pageError', error))
             .finally => @loaded = true

  from = 0
  per = 10

  @startNewPoll = ->
    ModalService.open PollCommonStartModal, poll: -> Records.polls.build()

  @searchPolls = =>
    if @fragment
      Records.polls.search(@fragment, per: 10)
    else
      $q.when()
  LoadingService.applyLoadingFunction @, 'searchPolls'

  @pollCollection =
    polls: =>
      _.sortBy(
        _.filter(Records.polls.find(@pollIds), (poll) =>
          _.isEmpty(@fragment) or poll.title.match(///#{@fragment}///i)), '-createdAt')

  return
