{ triggerResize } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'learnMore', ->
  scope: {title: '@', nuggets: '='}
  restrict: 'E'
  templateUrl: 'generated/components/learn_more/learn_more.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.open = ($mdMenu, $event) ->
      $scope.index = 0
      $scope.currentNugget = $scope.nuggets[$scope.index]
      $mdMenu.open($event)
      triggerResize(300)
      triggerResize(600)

    $scope.hasNext = ->
      $scope.index < $scope.nuggets.length - 1

    $scope.hasPrev = ->
      $scope.index > 0

    $scope.navigate = (diff) ->
      $scope.index += diff
      $scope.currentNugget = $scope.nuggets[$scope.index]
      triggerResize()

    $scope.next = -> $scope.navigate(1)
    $scope.prev = -> $scope.navigate(-1)
  ]
