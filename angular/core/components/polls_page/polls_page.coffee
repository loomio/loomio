angular.module('loomioApp').controller 'PollsPageController', ($scope, $q, $rootScope, Records, AbilityService, TranslationService, LoadingService, ModalService, PollCommonStartModal, RecordLoader) ->
  $rootScope.$broadcast('currentComponent', { page: 'pollsPage'})

  @pollIds = []
  @loader = new RecordLoader
    collection: 'polls'
    path: 'search'
    per: 25

  now = moment()
  @pollImportance = (poll) => poll.importance(now)

  Records.polls.searchResultsCount().then (response) =>
    @pollsCount = response

  @loadMore = =>
    @loader.loadMore().then (response) =>
      @pollIds = @pollIds.concat _.pluck(response.polls, 'id')
  LoadingService.applyLoadingFunction @, 'loadMore'
  @loader.fetchRecords().then(
    (response) => @pollIds = _.pluck(response.polls, 'id'),
    (error)    -> $rootScope.$broadcast('pageError', error)
  ).finally => @loaded = true

  @loadedCount = ->
    @pollCollection.polls().length

  @canLoadMore = ->
    !@fragment && @loadedCount() < @pollsCount

  @startNewPoll = ->
    ModalService.open PollCommonStartModal, poll: -> Records.polls.build(authorId: Session.user().id)

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
