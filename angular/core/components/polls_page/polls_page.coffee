angular.module('loomioApp').controller 'PollsPageController', ($scope, $q, $rootScope, Records, AbilityService, TranslationService, LoadingService, ModalService, PollCommonStartModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollsPage'})

  @pollIds = []
  from = 0
  per  = 10

  Records.polls.searchResultsCount().then (response) =>
    @pollsCount = response

  @loadMore = =>
    Records.polls.search(from: from, per: 1).then (response) =>
      from += per
      @pollIds = @pollIds.concat _.pluck(response.polls, 'id')
  LoadingService.applyLoadingFunction @, 'loadMore'
  @loadMore().then(null, (error) -> $rootScope.$broadcast('pageError', error))
             .finally => @loaded = true

  @loadedCount = ->
    @pollCollection.polls().length

  @canLoadMore = ->
    !@fragment && @loadedCount() < @pollsCount

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
