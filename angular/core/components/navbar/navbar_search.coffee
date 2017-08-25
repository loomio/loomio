angular.module('loomioApp').directive 'navbarSearch', ($location, Records, LmoUrlService) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ($scope) ->
    $scope.query = ''

    $scope.search = (query) ->
      return unless query && query.length > 3
      Records.searchResults.fetchByFragment(query).then ->
        Records.searchResults.find(query: query)

    $scope.goToItem = (result) ->
      return unless result
      $location.path LmoUrlService.searchResult(result)
      $scope.query = ''
