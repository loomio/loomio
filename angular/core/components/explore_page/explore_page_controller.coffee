angular.module('loomioApp').controller 'ExplorePageController', (Records, $rootScope, $timeout, AppConfig, LoadingService) ->

  @groupIds = []
  @perPage = AppConfig.pageSize.exploreGroups
  @canLoadMoreGroups = true
  @query = ""
  $timeout -> document.querySelector('#search-field').focus()

  @groups = =>
    Records.groups.find(@groupIds)

  @search = ->
    @groupIds = []
    @fetch()

  @fetch = =>
    Records.groups.fetchExploreGroups(@query, {from: @groupIds.length, per: @perPage}).then (object) =>
      @groupIds = @groupIds.concat _.pluck(object.groups, 'id')
      if (object.groups or []).length < @perPage
        @canLoadMoreGroups = false

  LoadingService.applyLoadingFunction @, 'search'
  @search()

  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl()})" }

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
