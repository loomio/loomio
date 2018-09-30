AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'
EventBus  = require 'shared/services/event_bus'

{ applyLoadingFunction } = require 'shared/helpers/apply'

$controller = ($rootScope, $timeout) ->
  EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'}

  @groupIds = []
  @resultsCount = 0
  @perPage = AppConfig.pageSize.exploreGroups
  @canLoadMoreGroups = true
  @query = ""
  $timeout -> document.querySelector('#search-field').focus()

  @groups = =>
    Records.groups.find(@groupIds)

  @handleSearchResults = (response) =>
    Records.groups.getExploreResultsCount(@query).then (data) =>
      @resultsCount = data.count
    @groupIds = @groupIds.concat _.map(response.groups, 'id')
    @canLoadMoreGroups = (response.groups || []).length == @perPage

  # changing the search term
  @search = =>
    @groupIds = []
    Records.groups.fetchExploreGroups(@query, per: @perPage).then(@handleSearchResults)
  applyLoadingFunction(@, 'search')
  @search()

  # clicking 'show more'
  @loadMore = =>
    Records.groups.fetchExploreGroups(@query, from: @groupIds.length, per: @perPage).then(@handleSearchResults)


  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl('small')})" }

  @groupDescription = (group) ->
    _.truncate group.description, {length: 100} if group.description

  @showMessage = ->
    !@searching &&
    @query &&
    @groups().length > 0

  @searchResultsMessage = ->
    if @groups().length == 1
      'explore_page.single_search_result'
    else
      'explore_page.multiple_search_results'

  @noResultsFound = ->
    !@searching && (@groups().length < @perPage || !@canLoadMoreGroups)

  return

$controller.$inject = ['$rootScope', '$timeout']
angular.module('loomioApp').controller 'ExplorePageController', $controller
