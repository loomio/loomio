angular.module('loomioApp').directive 'fileSelect', ->
  restrict: 'A'
  link: ($scope, $element, attrs) ->
    $element.attr 'type',     'file'
    $element.attr 'ng-model', 'file'
    $element.on 'change',   -> $scope.$eval(attrs.fileSelect)($element[0].files)
    $element.on '$destroy', -> $element.off()
