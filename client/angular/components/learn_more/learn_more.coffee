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

    $scope.hasNext = ->
      $scope.index < $scope.nuggets.length - 1

    $scope.hasPrev = ->
      $scope.index > 0

    $scope.next = ->
      $scope.index += 1
      $scope.currentNugget = $scope.nuggets[$scope.index]

    $scope.prev = ->
      $scope.index -= 1
      $scope.currentNugget = $scope.nuggets[$scope.index]
  ]
