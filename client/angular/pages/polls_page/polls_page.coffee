AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
RecordLoader   = require 'shared/services/record_loader'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

$controller = ($rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'polls_page.heading', page: 'pollsPage'}

  @statusFilters = _.map AppConfig.searchFilters.status, (filter) ->
    { name: _.capitalize(filter), value: filter }

  @groupFilters = _.map Session.user().groups(), (group) ->
    { name: group.fullName, value: group.key }

  @statusFilter = LmoUrlService.params().status
  @groupFilter  = LmoUrlService.params().group_key

  now = moment()
  @pollImportance = (poll) => poll.importance(now)

  @loadMore = =>
    @loader.loadMore().then (response) =>
      @pollIds = @pollIds.concat _.map(response.polls, 'id')
  applyLoadingFunction @, 'loadMore'

  @fetchRecords = =>
    LmoUrlService.params 'group_key', @groupFilter
    LmoUrlService.params 'status',    @statusFilter
    @pollIds = []

    @loader = new RecordLoader
      collection: 'polls'
      path: 'search'
      params: LmoUrlService.params()
      per: 25

    Records.polls.searchResultsCount(LmoUrlService.params()).then (response) =>
      @pollsCount = response.count

    @loader.fetchRecords().then (response) =>
      @group   = Records.groups.find(LmoUrlService.params().group_key)
      @pollIds = _.map(response.polls, 'id')
    , (error) ->
      EventBus.broadcast $rootScope, 'pageError', error

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
      Promise.resolve(true)
  applyLoadingFunction(@, 'searchPolls')

  @fetching = ->
    @fetchRecordsExecuting || @loadMoreExecuting

  @pollCollection =
    polls: =>
      _.sortBy(
        _.filter(Records.polls.find(@pollIds), (poll) =>
          _.isEmpty(@fragment) or poll.title.match(///#{@fragment}///i)), '-createdAt')

  return

$controller.$inject = ['$rootScope']
angular.module('loomioApp').controller 'PollsPageController', $controller
