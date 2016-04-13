angular.module('loomioApp').controller 'ExplorePageController', (Records, $rootScope, $timeout, AppConfig, LoadingService) ->

  @groups = []
  @perPage = AppConfig.pageSize.exploreGroups
  @query = ""
  $timeout -> document.querySelector('#search-field').focus()

  @changeSearchQuery = ->
    @loaded = 0
    @search()

  @search = =>
    from = @loaded
    Records.groups.fetchExploreGroups(@query, {from: @loaded, per: @perPage}).then (object) =>
      @groupIds = _.map object.groups, (group) -> group.id
      @groups = Records.groups.find(@groupIds)
      @loaded = @loaded + @perPage

  LoadingService.applyLoadingFunction @, 'search'
  @changeSearchQuery()

  @groupCover = (group) ->
    { 'background-image': "url(#{group.coverUrl()})" }

  @groupDescription = (group) ->
    _.trunc group.description, 100 if group.description

  @showMessage = ->
    !@searching &&
    @query &&
    @groups.length > 0

  @searchResultsMessage = ->
    if @groups.length == 1
      'explore_page.single_search_result'
    else
      'explore_page.multiple_search_results'

  @noResultsFound = ->
    !@searching && @groups.length == 0

  return
