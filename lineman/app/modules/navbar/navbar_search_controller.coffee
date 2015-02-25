angular.module('loomioApp').controller 'NavbarSearchController', ($scope, UserAuthService, Records, SearchResultModel) ->
  $scope.searchResults = []
  $scope.discussions   = []
  $scope.proposals     = []
  $scope.comments      = []

  $scope.searching = false

  $scope.noResultsFound = ->
    !$scope.searching && $scope.searchResults.length == 0

  $scope.availableGroups = ->
    UserAuthService.currentUser.groups() if UserAuthService.currentUser?

  $scope.getSearchResults = (query) ->
    if query?
      $scope.searching = true
      Records.searchResults.fetchByFragment($scope.query).then (response) ->
        $scope.searchResults = _.map response.search_results, (result) ->
          Records.searchResults.initialize result
        $scope.discussions = _.filter $scope.searchResults, (result) -> result.isDiscussion()
        $scope.proposals   = _.filter $scope.searchResults, (result) -> result.isProposal()
        $scope.comments    = _.filter $scope.searchResults, (result) -> result.isComment()
        $scope.searching = false
