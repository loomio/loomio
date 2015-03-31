angular.module('loomioApp').directive 'navbarSearch', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ($scope, $timeout, CurrentUser, Records, SearchResultModel, KeyEventService) ->
    $scope.searchResults = []
    $scope.query = ''
    $scope.focused = false

    $scope.$on '$locationChangeSuccess', ->
      $scope.query = ''

    $scope.searchField = ->
      angular.element('#primary-search-input')[0]

    $scope.shouldExecuteWithSearchField = (active) ->
      active == $scope.searchField() or KeyEventService.defaultShouldExecute(active)

    KeyEventService.setKeyEvent $scope, 'pressedEsc', ->
      $scope.searchField().blur()
      $scope.query = ''
    , $scope.shouldExecuteWithSearchField

    KeyEventService.setKeyEvent $scope, 'pressedSlash', (active) ->
      $scope.searchField().focus()
      $scope.query = ''

    KeyEventService.setKeyEvent $scope, 'pressedUpArrow', (active) ->
      alert('up arrow!')
    , $scope.shouldExecuteWithSearchField

    KeyEventService.setKeyEvent $scope, 'pressedDownArrow', (active) ->
      alert('down arrow!')
    , $scope.shouldExecuteWithSearchField

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
