angular.module('loomioApp').controller 'NavbarSearchController', ($scope, $timeout, UserAuthService, Records, SearchResultModel) ->
  $scope.searchResults = []
  $scope.searching = false

  $scope.clear = (showDropdown) ->
    $scope.query = null
    if showDropdown
      angular.element('.navbar-search-input input').focus()
      $scope.showDropdown()
    else
      $scope.hideDropdown()

  $scope.showDropdown = ->
    $scope.dropdown = true

  $scope.hideDropdown = ->
    $timeout (-> $scope.dropdown = false), 100

  $scope.noResultsFound = ->
    !$scope.searching && $scope.searchResults.length == 0

  $scope.availableGroups = ->
    UserAuthService.currentUser.groups() if UserAuthService.currentUser?

  $scope.getSearchResults = (query) ->
    if query?
      $scope.currentSearchQuery = query
      $scope.searching = true
      Records.search_results.fetchByFragment($scope.query).then (response) ->
        $scope.searchResults = _.map response.search_results, (result) ->
          Records.search_results.initialize result
        if $scope.currentSearchQuery == query
          $scope.searching = false
