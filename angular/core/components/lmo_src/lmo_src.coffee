angular.module('loomioApp').directive 'lmoSrc', (LmoUrlService) ->
  restrict: 'A'
  scope:
    path: '@lmoSrc'
  link: (scope, elem) ->
    scope.$watch 'path', ->
      elem.attr 'src', LmoUrlService.srcFor(scope.path)
