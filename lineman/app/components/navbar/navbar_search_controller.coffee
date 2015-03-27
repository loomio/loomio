angular.module('loomioApp').controller 'NavbarSearchController', ($scope, $timeout, CurrentUser, Records, SearchResultModel) ->
  $scope.searchResults = []
  $scope.query = ''
  $scope.focused = false

  $scope.$on '$locationChangeSuccess', ->
    $scope.query = ''

  $scope.setFocused = (bool) ->
    if bool
      $scope.focused = bool
    else
      $timeout ->
        $scope.focused = bool
      ,
        100

  $scope.showDropdown = ->
    $scope.focused || $scope.query.length > 0

  $scope.clearAndFocusInput = ->
    $scope.query = ''
    angular.element('.navbar-search-input input').focus()

  $scope.queryPresent = ->
    $scope.query.length > 0

  $scope.queryEmpty = ->
    $scope.query.length == 0

  $scope.noResultsFound = ->
    !$scope.searching && $scope.searchResults.length == 0

  $scope.groups = ->
    if $scope.queryPresent()
      # match groups where all words are present in group name
      _.filter CurrentUser.groups(), (group) ->
        _.all _.words($scope.query), (word) ->
          _.contains(group.fullName().toLowerCase(), word.toLowerCase())
    else
      CurrentUser.groups()

  $scope.groupNames = ->
    _.map $scope.groups(), (group) -> group.fullName()

  $scope.getSearchResults = (query) ->
    if query?
      $scope.currentSearchQuery = query
      $scope.searching = true
      Records.searchResults.fetchByFragment($scope.query).then (response) ->
        $scope.searchResults = _.map response.search_results, (result) ->
          Records.searchResults.initialize result

        if $scope.currentSearchQuery == query
          $scope.searching = false
