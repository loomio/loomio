angular.module('loomioApp').directive 'navbarSearch', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ($scope, $element, $timeout, CurrentUser, Records, SearchResultModel, KeyEventService) ->
    $scope.searchResults = []
    $scope.query = ''
    $scope.focused = false
    $scope.highlighted = null

    $scope.closeSearchDropdown = (e) ->
      target = e.currentTarget if e?
      $timeout ->
        target.click() if target?
        $scope.focused = false
        $scope.query = ''
        $scope.updateHighlighted null

    $scope.handleSearchBlur = ->
      return if $element[0].contains document.activeElement
      $scope.closeSearchDropdown()

    highlightables = ->
      document.querySelectorAll('.navbar-search-list-option')

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
      angular.element(document.querySelector('#primary-search-input'))[0]

    $scope.shouldExecuteWithSearchField = (active, event) ->
      active == $scope.searchField() or KeyEventService.defaultShouldExecute(active, event)

    KeyEventService.registerKeyEvent $scope, 'pressedEsc', ->
      $scope.searchField().blur()
      $scope.query = ''
    , $scope.shouldExecuteWithSearchField

    KeyEventService.registerKeyEvent $scope, 'pressedSlash', (active) ->
      $scope.searchField().focus()
      $scope.query = ''

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', ->
      if $scope.highlightedSelection()
        $scope.closeSearchDropdown(document.activeElement)
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

    $scope.clearAndFocusInput = ->
      $scope.closeSearchDropdown()
      $scope.searchField().focus()

    $scope.queryPresent = ->
      $scope.query.length > 0

    $scope.queryEmpty = ->
      $scope.query.length == 0

    $scope.noResultsFound = ->
      !$scope.searching && $scope.searchResults.length == 0

    $scope.groups = ->
      return CurrentUser.groups() unless $scope.queryPresent()
      # match groups where all words are present in group name
      _.filter CurrentUser.groups(), (group) ->
        _.all _.words($scope.query), (word) ->
          _.contains(group.fullName().toLowerCase(), word.toLowerCase())

    $scope.getSearchResults = (query) ->
      if query?
        $scope.updateHighlighted(null)
        $scope.currentSearchQuery = query
        $scope.searching = true
        Records.searchResults.fetchByFragment($scope.query).then ->
          $scope.searchResults = Records.searchResults.find(query: query)
          _.map $scope.searchResults, (result) -> result.remove()
          $scope.searching = false if $scope.currentSearchQuery == query
