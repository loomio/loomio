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

    $scope.hasNext = ->
      $scope.index < $scope.nuggets.length - 1

    $scope.hasPrev = ->
      $scope.index > 0

    $scope.next = -> navigate(1)
    $scope.prev = -> navigate(-1)

    navigate = (diff) ->
      $scope.index += diff
      $scope.currentNugget = $scope.nuggets[$scope.index]
      triggerResize()
  ]
