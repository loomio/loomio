angular.module('loomioApp').directive 'navbarSearch', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ($scope, $timeout, CurrentUser, Records, SearchResultModel, KeyEventService) ->
    $scope.searchResults = []
    $scope.query = ''
    $scope.focused = false
    $scope.hightlighted = null

    $scope.$on '$locationChangeSuccess', ->
      $scope.query = ''

    highlightables = ->
      angular.element('.navbar-search-list-option:visible')

    $scope.highlightedSelection = ->
      highlightables()[$scope.highlighted]

    $scope.updateHighlighted = (index) ->
      $scope.highlighted = index
      _.map highlightables(), (element) -> element.classList.remove("is-active")
      if $scope.highlightedSelection()?
        $scope.highlightedSelection().firstChild.focus()
        $scope.highlightedSelection().classList.add("is-active")
        # scroll to newly highlighted element?

    $scope.searchField = ->
      angular.element('#primary-search-input')[0]

    $scope.shouldExecuteWithSearchField = (active) ->
      active == $scope.searchField() or KeyEventService.defaultShouldExecute(active)

    KeyEventService.registerKeyEvent $scope, 'pressedEsc', ->
      $scope.searchField().blur()
      $scope.query = ''
    , $scope.shouldExecuteWithSearchField

    KeyEventService.registerKeyEvent $scope, 'pressedSlash', (active) ->
      $scope.searchField().focus()
      $scope.query = ''

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', ->
      if el = $scope.highlightedSelection()
        el.firstChild.click()
        $scope.searchField().blur()
    , $scope.shouldExecuteWithSearchField

    KeyEventService.registerKeyEvent $scope, 'pressedUpArrow', (active) ->
      if isNaN(parseInt($scope.highlighted)) or $scope.highlighted == 0
        $scope.updateHighlighted(highlightables().length - 1)
      else
        $scope.updateHighlighted($scope.highlighted - 1)
    , $scope.shouldExecuteWithSearchField

    KeyEventService.registerKeyEvent $scope, 'pressedDownArrow', (active) ->
      if isNaN(parseInt($scope.highlighted)) or $scope.highlighted == highlightables().length - 1
        $scope.updateHighlighted(0)
      else
        $scope.updateHighlighted($scope.highlighted + 1)
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
      $scope.focused

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
        $scope.updateHighlighted(null)
        $scope.currentSearchQuery = query
        $scope.searching = true
        Records.searchResults.fetchByFragment($scope.query).then (response) ->
          $scope.searchResults = _.map response.search_results, (result) ->
            Records.searchResults.initialize result

          if $scope.currentSearchQuery == query
            $scope.searching = false
