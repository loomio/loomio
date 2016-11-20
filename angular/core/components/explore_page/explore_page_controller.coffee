angular.module('loomioApp').controller 'ExplorePageController', (Records, $rootScope, $timeout, AppConfig, LoadingService) ->
  $rootScope.$broadcast('currentComponent', { page: 'explorePage'})

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
    @groupIds = @groupIds.concat _.pluck(response.groups, 'id')
    @canLoadMoreGroups = (response.groups || []).length == @perPage

  # changing the search term
  @search = =>
    @groupIds = []
    Records.groups.fetchExploreGroups(@query, per: @perPage).then(@handleSearchResults)

  # clicking 'show more'
  @loadMore = =>
    Records.groups.fetchExploreGroups(@query, from: @groupIds.length, per: @perPage).then(@handleSearchResults)

  LoadingService.applyLoadingFunction @, 'search'
  @search()

  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl('small')})" }

  @groupDescription = (group) ->
    _.trunc group.description, 100 if group.description

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
