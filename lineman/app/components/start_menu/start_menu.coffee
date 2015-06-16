angular.module('loomioApp').directive 'startMenu', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/start_menu/start_menu.html'
  replace: true
  controller: ($scope) ->

    $scope.$on 'modalOpened', ->
      $scope.startMenuOpen = false

    $scope.toggleStartMenu = ->
      $scope.startMenuOpen = !$scope.startMenuOpen
