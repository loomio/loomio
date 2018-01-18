angular.module('loomioApp').directive 'loadingContent', ->
  scope: {blockCount: '=?', lineCount: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/loading_content/loading_content.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.blocks = new Array($scope.blockCount or 1)
    $scope.lines = new Array($scope.lineCount or 3)
  ]
