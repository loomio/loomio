AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
RecordLoader   = require 'shared/services/record_loader.coffee'

{ applyLoadingFunction } = require 'angular/helpers/loading.coffee'

angular.module('loomioApp').controller 'PollsPageController', ($scope, $location, $q, $rootScope, ModalService) ->
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
  applyLoadingFunction @, 'loadMore'

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

  applyLoadingFunction @, 'fetchRecords'
  @fetchRecords()

  @loadedCount = ->
    @pollCollection.polls().length

  @canLoadMore = ->
    !@fragment && @loadedCount() < @pollsCount

  @startNewPoll = ->
    ModalService.open 'PollCommonStartModal', poll: -> Records.polls.build(authorId: Session.user().id)

  @searchPolls = =>
    if @fragment
      Records.polls.search(query: @fragment, per: 10)
    else
      $q.when()
  applyLoadingFunction @, 'searchPolls'

  @fetching = ->
    @fetchRecordsExecuting || @loadMoreExecuting

  @pollCollection =
    polls: =>
      _.sortBy(
        _.filter(Records.polls.find(@pollIds), (poll) =>
          _.isEmpty(@fragment) or poll.title.match(///#{@fragment}///i)), '-createdAt')

  return
