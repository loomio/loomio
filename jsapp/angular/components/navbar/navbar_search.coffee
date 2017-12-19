angular.module('loomioApp').directive 'navbarSearch', ($timeout, $location, Records, LmoUrlService) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ($scope) ->
    $scope.isOpen = false

    $scope.$on 'currentComponent', ->
      $scope.isOpen = false

    $scope.open = ->
      $scope.isOpen = true
      $timeout ->
        document.querySelector('.navbar-search input').focus()

    $scope.query = ''

    $scope.search = (query) ->
      return unless query && query.length > 3
      Records.searchResults.fetchByFragment(query).then ->
        Records.searchResults.find(query: query)

    $scope.goToItem = (result) ->
      return unless result
      $location.path LmoUrlService.searchResult(result)
      $scope.query = ''
