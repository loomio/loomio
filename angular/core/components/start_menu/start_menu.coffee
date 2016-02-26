angular.module('loomioApp').directive 'startMenu', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu.html'
  replace: true
  controller: ($scope) ->

    $scope.$on 'modalOpened', ->
      $scope.startMenuOpen = false

    $scope.$on 'currentComponent', ->
      $scope.currentGroup = null

    $scope.$on 'viewingGroup', (event, group) ->
      $scope.currentGroup = group

    $scope.$on 'viewingThread', (event, discussion) ->
      $scope.currentGroup = discussion.group()

    $scope.toggleStartMenu = ->
      $scope.startMenuOpen = !$scope.startMenuOpen
