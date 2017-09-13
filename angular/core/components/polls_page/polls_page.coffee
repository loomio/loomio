angular.module('loomioApp').controller 'PollsPageController', ($scope, $location, $q, $rootScope, AppConfig, Records, Session, AbilityService, LoadingService, ModalService, PollCommonStartModal, RecordLoader) ->
  $rootScope.$broadcast 'currentComponent', { titleKey: 'polls_page.heading', page: 'pollsPage'}

  @statusFilters = _.map AppConfig.searchFilters.status, (filter) ->
    { name: _.capitalize(filter), value: filter }

  @groupFilters = _.map Session.user().groups(), (group) ->
    { name: group.fullName, value: group.key }

  @statusFilter = $location.search().status
  @groupFilter  = $location.search().group_key

  now = moment()
  @pollImportance = (poll) => poll.importance(now)

  @loadMore = =>
    @loader.loadMore().then (response) =>
      @pollIds = @pollIds.concat _.pluck(response.polls, 'id')
  LoadingService.applyLoadingFunction @, 'loadMore'

  @fetchRecords = =>
    $location.search 'group_key', @groupFilter
    $location.search 'status',    @statusFilter
    @pollIds = []

    @loader = new RecordLoader
      collection: 'polls'
      path: 'search'
      params: $location.search()
      per: 25

    Records.polls.searchResultsCount($location.search()).then (response) =>
      @pollsCount = response

    @loader.fetchRecords().then (response) =>
      @group   = Records.groups.find($location.search().group_key)
      @pollIds = _.pluck(response.polls, 'id')
    , (error) ->
      $rootScope.$broadcast('pageError', error)

  LoadingService.applyLoadingFunction @, 'fetchRecords'
  @fetchRecords()

  @loadedCount = ->
    @pollCollection.polls().length

  @canLoadMore = ->
    !@fragment && @loadedCount() < @pollsCount

  @startNewPoll = ->
    ModalService.open PollCommonStartModal, poll: -> Records.polls.build(authorId: Session.user().id)

  @searchPolls = =>
    if @fragment
      Records.polls.search(query: @fragment, per: 10)
    else
      $q.when()
  LoadingService.applyLoadingFunction @, 'searchPolls'

  @fetching = ->
    @fetchRecordsExecuting || @loadMoreExecuting

  @pollCollection =
    polls: =>
      _.sortBy(
        _.filter(Records.polls.find(@pollIds), (poll) =>
          _.isEmpty(@fragment) or poll.title.match(///#{@fragment}///i)), '-createdAt')

  return
