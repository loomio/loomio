angular.module('loomioApp').directive 'fileDrop', ->
  restrict: 'A'
  link: ($scope, $element, attrs) ->
    $element.on 'dragover',  (event) ->
      event.preventDefault()
      $scope.dragging = true
    $element.on 'dragenter', (event) ->
      event.preventDefault()
      $scope.dragging = true
    $element.on 'dragleave', (event) ->
      event.preventDefault()
      $scope.dragging = false
    $element.on 'drop',      (event) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      $scope.$eval(attrs.fileDrop)(event)
      $scope.dragging = false
